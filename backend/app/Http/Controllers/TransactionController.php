<?php 

namespace App\Http\Controllers;

use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class TransactionController extends Controller
{
    public function makePurchase(Request $request)
    {
        $request->validate([
            'amount'           => 'required|numeric',
            'transaction_type' => 'required|in:balance,premium',
        ]);

        // Build the payload for the Konnect Gateway
        // (Implementation details may vary depending on Konnect's API specs)
        $konnectPayload = [
            'amount'       => $request->amount,
            'currency'     => 'USD',
            'orderId'      => uniqid('order_'),
            'callbackUrl'  => 'http://your-domain.com/payment/callback',
            // Additional fields if required by Konnect
        ];

        try {
            // Make a POST request to Konnect Gateway
            $response = Http::post('https://api.konnect.network/api/v2/konnect-gateway', $konnectPayload);

            if ($response->successful()) {
                $paymentResponse = $response->json();

                // Check if payment was successful
                // For example, Konnect might return: ["status" => "success", ...]
                if (isset($paymentResponse['status']) && $paymentResponse['status'] === 'success') {
                    
                    // Payment successful, create transaction record
                    $transaction = Transaction::create([
                        'user_id'          => $request->user()->id,
                        'amount'           => $request->amount,
                        'transaction_type' => $request->transaction_type,
                    ]);

                    // If it's a premium purchase, upgrade user to premium
                    if ($request->transaction_type === 'premium') {
                        $request->user()->update(['is_premium' => true]);
                    }

                    return response()->json([
                        'message'     => 'Payment successful',
                        'transaction' => $transaction,
                        'konnect'     => $paymentResponse,
                    ], 201);

                } else {
                    return response()->json([
                        'message' => 'Payment failed',
                        'error'   => $paymentResponse,
                    ], 400);
                }
            } else {
                return response()->json([
                    'message' => 'Failed to reach Konnect Gateway',
                    'error'   => $response->json(),
                ], 502);
            }
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Payment process error',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }
}
