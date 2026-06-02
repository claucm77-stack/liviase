const admin = require('firebase-admin');
const path = require('path');

const serviceAccountPath = path.resolve(__dirname, './firebase-service-account.json');
const serviceAccount = require(serviceAccountPath);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

const contenidos = [
  {
    id: 'contenido-ejemplo-1',
    titulo: 'Cómo iniciar un microemprendimiento',
    descripcion: 'Guía básica para comenzar un pequeño negocio local.',
    tipo: 'texto',
    url: 'https://example.com/microemprendimiento',
    imagen: 'https://picsum.photos/seed/micro1/800/400',
    categoria: 'Emprendimiento',
    autorId: 'educador_demo',
    fechaCreacion: new Date().toISOString(),
    estado: 'activo',
    destacado: true,
    favoritos: [],
    vistos: [],
  },
  {
    id: 'contenido-ejemplo-2',
    titulo: 'Finanzas personales para negocios',
    descripcion: 'Video introductorio sobre flujo de caja y presupuesto.',
    tipo: 'video',
    url: 'https://example.com/video-finanzas',
    imagen: 'https://picsum.photos/seed/micro2/800/400',
    categoria: 'Finanzas',
    autorId: 'educador_demo',
    fechaCreacion: new Date(Date.now() - 3600 * 1000).toISOString(),
    estado: 'activo',
    destacado: false,
    favoritos: [],
    vistos: [],
  },
  {
    id: 'contenido-ejemplo-3',
    titulo: 'Marketing digital para principiantes',
    descripcion: 'Principios clave para promocionar tu negocio en redes.',
    tipo: 'pdf',
    url: 'https://example.com/marketing.pdf',
    imagen: 'https://picsum.photos/seed/micro3/800/400',
    categoria: 'Marketing',
    autorId: 'educador_demo',
    fechaCreacion: new Date(Date.now() - 2 * 3600 * 1000).toISOString(),
    estado: 'activo',
    destacado: true,
    favoritos: [],
    vistos: [],
  },
  {
    id: 'contenido-ejemplo-4',
    titulo: 'Atención al cliente efectiva',
    descripcion: 'Buenas prácticas para fidelizar clientes.',
    tipo: 'texto',
    url: 'https://example.com/atencion-cliente',
    imagen: 'https://picsum.photos/seed/micro4/800/400',
    categoria: 'Gestión',
    autorId: 'educador_demo',
    fechaCreacion: new Date(Date.now() - 3 * 3600 * 1000).toISOString(),
    estado: 'activo',
    destacado: false,
    favoritos: [],
    vistos: [],
  },
  {
    id: 'contenido-ejemplo-5',
    titulo: 'Checklist legal básico',
    descripcion: 'Resumen de requisitos iniciales para operar formalmente.',
    tipo: 'pdf',
    url: 'https://example.com/checklist-legal.pdf',
    imagen: 'https://picsum.photos/seed/micro5/800/400',
    categoria: 'Legal',
    autorId: 'educador_demo',
    fechaCreacion: new Date(Date.now() - 4 * 3600 * 1000).toISOString(),
    estado: 'activo',
    destacado: false,
    favoritos: [],
    vistos: [],
  },
];

async function seed() {
  try {
    for (const item of contenidos) {
      await db.collection('contenidos').doc(item.id).set(item, { merge: true });
      console.log(`✔ Contenido creado/actualizado: ${item.id}`);
    }
    console.log('\nSeed completado correctamente.');
    process.exit(0);
  } catch (error) {
    console.error('Error al sembrar contenidos:', error);
    process.exit(1);
  }
}

seed();
