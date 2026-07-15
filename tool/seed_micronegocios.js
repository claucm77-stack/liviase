/* eslint-disable no-console */
const path = require('path');
const admin = require(path.resolve(__dirname, '../backend/node_modules/firebase-admin'));
const serviceAccount = require(path.resolve(__dirname, '../backend/firebase-service-account.json'));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

async function seedMicrobusinesses() {
  const now = new Date();

  const items = [
    {
      id: 'micro_001',
      nombre: 'Panadería La Esquina',
      descripcion: 'Pan artesanal, empanadas y café para llevar.',
      categoria: 'Alimentos',
      direccion: 'Av. Principal 123, Centro',
      latitud: -12.0464,
      longitud: -77.0428,
      imagen: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
      propietarioId: 'educador_demo_01',
      contacto: '+51 999 111 222',
      horario: 'Lun-Sáb 6:00 - 20:00',
      estado: 'activo',
      fechaCreacion: now.toISOString(),
      favoritos: [],
      ratingPromedio: 4.6,
      totalCalificaciones: 22,
    },
    {
      id: 'micro_002',
      nombre: 'Artesanías Inti',
      descripcion: 'Souvenirs, tejidos y decoración hecha a mano.',
      categoria: 'Artesanías',
      direccion: 'Jr. Sol 456, Mercado Central',
      latitud: -12.0451,
      longitud: -77.0304,
      imagen: 'https://images.unsplash.com/photo-1459908676235-d5f02a50184b?w=800',
      propietarioId: 'educador_demo_02',
      contacto: '+51 988 333 444',
      horario: 'Lun-Dom 9:00 - 19:00',
      estado: 'activo',
      fechaCreacion: new Date(now.getTime() - 3600 * 1000).toISOString(),
      favoritos: [],
      ratingPromedio: 4.8,
      totalCalificaciones: 31,
    },
    {
      id: 'micro_003',
      nombre: 'TecnoBarrio',
      descripcion: 'Reparación de celulares, accesorios y soporte técnico.',
      categoria: 'Tecnología',
      direccion: 'Calle Lima 789, Urb. Norte',
      latitud: -12.0522,
      longitud: -77.0335,
      imagen: 'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=800',
      propietarioId: 'educador_demo_01',
      contacto: '+51 977 555 666',
      horario: 'Lun-Sáb 10:00 - 18:00',
      estado: 'activo',
      fechaCreacion: new Date(now.getTime() - 7200 * 1000).toISOString(),
      favoritos: [],
      ratingPromedio: 4.3,
      totalCalificaciones: 14,
    },
    {
      id: 'micro_004',
      nombre: 'Costuras Rosita',
      descripcion: 'Arreglos de ropa, confección y bordado personalizado.',
      categoria: 'Moda',
      direccion: 'Pasaje Flores 321, Sur',
      latitud: -12.0601,
      longitud: -77.0411,
      imagen: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800',
      propietarioId: 'educador_demo_03',
      contacto: '+51 966 777 888',
      horario: 'Lun-Vie 8:30 - 17:30',
      estado: 'inactivo',
      fechaCreacion: new Date(now.getTime() - 10800 * 1000).toISOString(),
      favoritos: [],
      ratingPromedio: 4.1,
      totalCalificaciones: 9,
    },
  ];

  const batch = db.batch();

  for (const item of items) {
    const ref = db.collection('micronegocios').doc(item.id);
    batch.set(ref, item, { merge: true });

    const singularRef = db.collection('micronegocio').doc(item.id);
    batch.set(singularRef, item, { merge: true });
  }

  await batch.commit();
  console.log(`✅ Seed completado: ${items.length} micronegocios cargados.`);
}

seedMicrobusinesses()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('❌ Error al cargar seed de micronegocios:', error);
    process.exit(1);
  });
