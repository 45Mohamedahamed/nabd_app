const stripe = require('stripe')('sk_test_your_secret_key_here'); // Secret Key من Stripe Dashboard
const express = require('express');
const app = express();

app.use(express.json());

app.post('/payment-sheet', async (req, res) => {
  try {
    // 1. إنشاء عميل (اختياري لكنه احترافي لحفظ البطاقات)
    const customer = await stripe.customers.create();

    // 2. إنشاء نية الدفع (Payment Intent)
    const paymentIntent = await stripe.paymentIntents.create({
      amount: req.body.amount, // المبلغ بالقرش (مثلاً 1000 = 10 دولار)
      currency: 'usd',
      customer: customer.id,
      // تفعيل طرق الدفع التلقائية (Apple Pay / Google Pay بتظهر لوحدها هنا)
      automatic_payment_methods: { enabled: true },
    });

    // 3. إرسال البيانات للتطبيق
    res.json({
      paymentIntent: paymentIntent.client_secret,
      customer: customer.id,
      publishableKey: 'pk_test_your_publishable_key_here'
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.listen(3000, () => console.log('🚀 السيرفر شغال على بورت 3000'));