/* eslint-disable no-console */
const path = require('path');
const admin = require(path.resolve(__dirname, '../backend/node_modules/firebase-admin'));
const serviceAccount = require(path.resolve(
  __dirname,
  '../backend/firebase-service-account.json',
));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const auth = admin.auth();
const db = admin.firestore();

const demoUsers = [
  {
    email: 'micro@liviase.local',
    password: 'Micro12345*',
    displayName: 'Microempresario Demo',
    role: 'microempresario',
  },
  {
    email: 'docente@liviase.local',
    password: 'Docente12345*',
    displayName: 'Docente Demo',
    role: 'docente',
  },
  {
    email: 'coordinador@liviase.local',
    password: 'Coord12345*',
    displayName: 'Coordinador Academico Demo',
    role: 'docente_admin',
  },
  {
    email: 'admin@plataforma.com',
    password: 'Admin12345*',
    displayName: 'Administrador TI Demo',
    role: 'admin_ti',
  },
];

async function upsertDemoUser(demoUser) {
  let userRecord;

  try {
    userRecord = await auth.getUserByEmail(demoUser.email);
    userRecord = await auth.updateUser(userRecord.uid, {
      password: demoUser.password,
      displayName: demoUser.displayName,
      emailVerified: true,
      disabled: false,
    });
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
    userRecord = await auth.createUser({
      email: demoUser.email,
      password: demoUser.password,
      displayName: demoUser.displayName,
      emailVerified: true,
      disabled: false,
    });
  }

  await db.collection('users').doc(userRecord.uid).set(
    {
      uid: userRecord.uid,
      nombre: demoUser.displayName,
      name: demoUser.displayName,
      email: demoUser.email,
      rol: demoUser.role,
      role: demoUser.role,
      photoUrl: '',
      isActive: true,
      is_active: true,
      createdAt: new Date().toISOString(),
    },
    { merge: true },
  );

  console.log(`Usuario demo listo: ${demoUser.email} / ${demoUser.password} (${demoUser.role})`);
}

async function run() {
  for (const demoUser of demoUsers) {
    await upsertDemoUser(demoUser);
  }
}

run().catch((error) => {
  console.error('No se pudieron crear los usuarios demo:', error);
  process.exit(1);
});
