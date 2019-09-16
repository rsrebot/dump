const parseArgs = require("minimist");

const argv = parseArgs(process.argv.slice(2));

const MongoClient = require("mongodb").MongoClient;
const config = require("dos-config");
const fs = require("fs");

const url = config.mongoUrl;
const client = new MongoClient(url, { maxSocketTimeoutMS: 300000 });
let db;

const parseDomainFromEmail = addr => {
  const parsed = emailAddresses.parseOneAddress(addr);

  return parsed ? parsed.domain : null;
};

const emailMatchesDomains = (email, domains) =>
  domains.some(domain => {
    const regExp = new RegExp(`@(\\w{1,30}\\.)?${domain}(\\.\\w{2,3})?$`, "i");
    return regExp.test(email);
  });

(async () => {
  let progress = 0;
  try {
    db = (await client.connect()).db();
    const companyName = argv._[0];
    console.log(`Company: ${companyName}`);
    const company = await db
      .collection("companies")
      .findOne({ id: companyName });

    if (!company) {
      console.log(`Company ${companyName} not found!`);
      process.exit(1);
    }

    const t = Date.now();
    const workspaces = await db.collection("profiles").find(
      {
        type: "organization",
        $or: [{ company: companyName }, { company: null }]
      },
      { projection: { username: 1, company: 1, billingEmail: 1 } }
    );

    const companyWorkspaces = [];
    while (await workspaces.hasNext()) {
      const w = await workspaces.next();
      progress++;
      if (
        w.company ||
        emailMatchesDomains(w.billingEmail, company.domains || [])
      ) {
        companyWorkspaces.push(w);
      }
    }
    console.log(`Elapsed: ${Date.now() - t} ms.`);
    // console.log(companyWorkspaces);
    fs.writeFileSync(
      `${companyName}-workspaces.txt`,
      companyWorkspaces.map(w => w.username).join("\n")
    );
    console.log(`Done`);
  } catch (e) {
    console.log(e);
  } finally {
    console.log(`Records processed ${progress}`);
    client.close();
    process.exit(0);
  }
})();
