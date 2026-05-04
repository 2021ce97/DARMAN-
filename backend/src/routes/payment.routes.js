import { getFirestore } from '../config/firebase.js';
import { authenticate } from '../middleware/auth.middleware.js';
import paymentService from '../services/payment_service.js';

export default async function paymentRoutes(fastify, options) {
  const db = getFirestore();

  // Create payment intent
  fastify.post('/create-intent', { preHandler: authenticate }, async (request, reply) => {
    try {
      const { bookingId, amount, method } = request.body;

      if (!bookingId || !amount || !method) {
        return reply.status(400).send({
          error: { message: 'Missing required fields', statusCode: 400 },
        });
      }

      // Create payment intent with HesabPay
      const paymentResult = await paymentService.createPaymentIntent(
        amount,
        'AFN',
        { bookingId, userId: request.user.uid }
      );

      if (!paymentResult.success) {
        return reply.status(500).send({
          error: { message: paymentResult.error || 'Payment creation failed', statusCode: 500 },
        });
      }

      // Store payment in database
      const paymentData = {
        bookingId,
        patientId: request.user.uid,
        amount,
        currency: 'AFN',
        method,
        status: 'pending',
        paymentId: paymentResult.paymentId,
        createdAt: new Date().toISOString(),
      };

      const paymentRef = await db.collection('payments').add(paymentData);

      return reply.status(201).send({
        success: true,
        message: 'Payment intent created',
        data: {
          id: paymentRef.id,
          paymentId: paymentResult.paymentId,
          ...paymentData,
          mockMode: paymentResult.mockMode || false,
        },
      });
    } catch (error) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: { message: error.message, statusCode: 500 },
      });
    }
  });

  // Confirm payment
  fastify.post('/:id/confirm', { preHandler: authenticate }, async (request, reply) => {
    try {
      const { id } = request.params;
      const { paymentMethod } = request.body;

      // Get payment from database
      const paymentDoc = await db.collection('payments').doc(id).get();

      if (!paymentDoc.exists) {
        return reply.status(404).send({
          error: { message: 'Payment not found', statusCode: 404 },
        });
      }

      const paymentData = paymentDoc.data();

      // Confirm payment with HesabPay
      const confirmResult = await paymentService.confirmPayment(
        paymentData.paymentId,
        paymentMethod || paymentData.method
      );

      if (!confirmResult.success) {
        return reply.status(500).send({
          error: { message: confirmResult.error || 'Payment confirmation failed', statusCode: 500 },
        });
      }

      // Update payment status
      await db.collection('payments').doc(id).update({
        status: 'completed',
        transactionId: confirmResult.transactionId,
        completedAt: new Date().toISOString(),
      });

      // Update booking payment status
      if (paymentData.bookingId) {
        await db.collection('bookings').doc(paymentData.bookingId).update({
          paymentStatus: 'completed',
          status: 'confirmed',
        });
      }

      return reply.send({
        success: true,
        message: 'Payment confirmed successfully',
        data: {
          transactionId: confirmResult.transactionId,
          mockMode: confirmResult.mockMode || false,
        },
      });
    } catch (error) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: { message: error.message, statusCode: 500 },
      });
    }
  });

  // Get payment status
  fastify.get('/:id/status', { preHandler: authenticate }, async (request, reply) => {
    try {
      const { id } = request.params;

      const paymentDoc = await db.collection('payments').doc(id).get();

      if (!paymentDoc.exists) {
        return reply.status(404).send({
          error: { message: 'Payment not found', statusCode: 404 },
        });
      }

      const paymentData = paymentDoc.data();

      // Get status from HesabPay
      const statusResult = await paymentService.getPaymentStatus(paymentData.paymentId);

      return reply.send({
        success: true,
        data: {
          id,
          status: statusResult.status || paymentData.status,
          amount: paymentData.amount,
          currency: paymentData.currency,
          createdAt: paymentData.createdAt,
          completedAt: paymentData.completedAt,
          mockMode: statusResult.mockMode || false,
        },
      });
    } catch (error) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: { message: error.message, statusCode: 500 },
      });
    }
  });

  // Refund payment
  fastify.post('/:id/refund', { preHandler: authenticate }, async (request, reply) => {
    try {
      const { id } = request.params;
      const { amount } = request.body;

      const paymentDoc = await db.collection('payments').doc(id).get();

      if (!paymentDoc.exists) {
        return reply.status(404).send({
          error: { message: 'Payment not found', statusCode: 404 },
        });
      }

      const paymentData = paymentDoc.data();

      // Process refund with HesabPay
      const refundResult = await paymentService.refundPayment(paymentData.paymentId, amount);

      if (!refundResult.success) {
        return reply.status(500).send({
          error: { message: refundResult.error || 'Refund failed', statusCode: 500 },
        });
      }

      // Update payment status
      await db.collection('payments').doc(id).update({
        status: 'refunded',
        refundId: refundResult.refundId,
        refundedAt: new Date().toISOString(),
        refundAmount: refundResult.amount,
      });

      return reply.send({
        success: true,
        message: 'Payment refunded successfully',
        data: {
          refundId: refundResult.refundId,
          amount: refundResult.amount,
          mockMode: refundResult.mockMode || false,
        },
      });
    } catch (error) {
      fastify.log.error(error);
      return reply.status(500).send({
        error: { message: error.message, statusCode: 500 },
      });
    }
  });
}
