import { getFirestore } from '../config/firebase.js';
import { authenticate } from '../middleware/auth.middleware.js';

export default async function bookingRoutes(fastify, options) {
  const db = getFirestore();

  // Create a new booking
  fastify.post('/', { preHandler: authenticate }, async (request, reply) => {
    try {
      const { doctorId, date, timeSlot, type, notes } = request.body;

      if (!doctorId || !date || !timeSlot || !type) {
        return reply.status(400).send({
          error: { message: 'Missing required fields', statusCode: 400 },
        });
      }

      // Check if slot is available
      const availabilityDoc = await db.collection('doctors')
        .doc(doctorId)
        .collection('availability')
        .doc(date)
        .get();

      if (!availabilityDoc.exists) {
        return reply.status(400).send({
          error: { message: 'No availability for this date', statusCode: 400 },
        });
      }

      const slots = availabilityDoc.data().slots || [];
      const slot = slots.find(s => s.time === timeSlot && s.available);

      if (!slot) {
        return reply.status(400).send({
          error: { message: 'Time slot not available', statusCode: 400 },
        });
      }

      // Create booking
      const bookingData = {
        patientId: request.user.uid,
        doctorId,
        date,
        timeSlot,
        type,
        notes: notes || '',
        status: 'pending',
        paymentStatus: 'pending',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const bookingRef = await db.collection('bookings').add(bookingData);

      // Mark slot as unavailable
      const updatedSlots = slots.map(s => 
        s.time === timeSlot ? { ...s, available: false } : s
      );

      await db.collection('doctors')
        .doc(doctorId)
        .collection('availability')
        .doc(date)
        .update({ slots: updatedSlots });

      return reply.status(201).send({
        success: true,
        message: 'Booking created successfully',
        data: { id: bookingRef.id, ...bookingData },
      });
    } catch (error) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: { message: error.message, statusCode: 500 },
      });
    }
  });

  // Get user bookings
  fastify.get('/my-bookings', { preHandler: authenticate }, async (request, reply) => {
    try {
      const { status, page = 1, limit = 20 } = request.query;
      
      let query = db.collection('bookings').where('patientId', '==', request.user.uid);

      if (status) {
        query = query.where('status', '==', status);
      }

      const snapshot = await query
        .orderBy('createdAt', 'desc')
        .limit(parseInt(limit))
        .get();

      const bookings = [];
      for (const doc of snapshot.docs) {
        const bookingData = doc.data();
        
        // Get doctor details
        const doctorDoc = await db.collection('doctors').doc(bookingData.doctorId).get();
        
        bookings.push({
          id: doc.id,
          ...bookingData,
          doctor: doctorDoc.exists ? doctorDoc.data() : null,
        });
      }

      return reply.send({
        success: true,
        data: bookings,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: bookings.length,
        },
      });
    } catch (error) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: { message: error.message, statusCode: 500 },
      });
    }
  });

  // Get booking by ID
  fastify.get('/:id', { preHandler: authenticate }, async (request, reply) => {
    try {
      const { id } = request.params;
      const bookingDoc = await db.collection('bookings').doc(id).get();

      if (!bookingDoc.exists) {
        return reply.status(404).send({
          error: { message: 'Booking not found', statusCode: 404 },
        });
      }

      const bookingData = bookingDoc.data();

      // Verify user has access to this booking
      if (bookingData.patientId !== request.user.uid && bookingData.doctorId !== request.user.uid) {
        return reply.status(403).send({
          error: { message: 'Access denied', statusCode: 403 },
        });
      }

      return reply.send({
        success: true,
        data: { id: bookingDoc.id, ...bookingData },
      });
    } catch (error) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: { message: error.message, statusCode: 500 },
      });
    }
  });

  // Cancel booking
  fastify.put('/:id/cancel', { preHandler: authenticate }, async (request, reply) => {
    try {
      const { id } = request.params;
      const bookingDoc = await db.collection('bookings').doc(id).get();

      if (!bookingDoc.exists) {
        return reply.status(404).send({
          error: { message: 'Booking not found', statusCode: 404 },
        });
      }

      const bookingData = bookingDoc.data();

      // Verify user has access to cancel this booking
      if (bookingData.patientId !== request.user.uid) {
        return reply.status(403).send({
          error: { message: 'Access denied', statusCode: 403 },
        });
      }

      // Update booking status
      await db.collection('bookings').doc(id).update({
        status: 'cancelled',
        updatedAt: new Date().toISOString(),
      });

      // Make slot available again
      const availabilityDoc = await db.collection('doctors')
        .doc(bookingData.doctorId)
        .collection('availability')
        .doc(bookingData.date)
        .get();

      if (availabilityDoc.exists) {
        const slots = availabilityDoc.data().slots || [];
        const updatedSlots = slots.map(s => 
          s.time === bookingData.timeSlot ? { ...s, available: true } : s
        );

        await db.collection('doctors')
          .doc(bookingData.doctorId)
          .collection('availability')
          .doc(bookingData.date)
          .update({ slots: updatedSlots });
      }

      return reply.send({
        success: true,
        message: 'Booking cancelled successfully',
      });
    } catch (error) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: { message: error.message, statusCode: 500 },
      });
    }
  });
}
