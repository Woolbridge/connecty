<?php 

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;


class DiscoveryController extends Controller
{
    public function getNearbyUsers(Request $request)
    {
        $radius = $request->query('radius', 1); // default 10 km
        $user = $request->user();

        if (!$user->latitude || !$user->longitude) {
            return response()->json(['message' => 'User location not set'], 400);
        }

        $nearbyUsers = User::where('id', '!=', $user->id)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->get()
            ->filter(function ($u) use ($user, $radius) {
                $distance = $this->calculateDistance(
                    $user->latitude,
                    $user->longitude,
                    $u->latitude,
                    $u->longitude
                );
                return $distance <= $radius;
            })
            ->values();

        return response()->json($nearbyUsers);
    }

    public function updateLocation(Request $request)
    {
        $request->validate([
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = $request->user();
        if (!$user) {
            Log::error('Unauthenticated request to update location');
            return response()->json(['message' => 'Unauthenticated'], 401);
        }
        Log::info('Authenticated user:', ['id' => $user->id]);
        Log::info('Request data:', $request->all());
        $user->update([
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
        ]);

        return response()->json(['message' => 'Location updated']);
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371; // km
        $latDistance = deg2rad($lat2 - $lat1);
        $lonDistance = deg2rad($lon2 - $lon1);

        $a = sin($latDistance / 2) * sin($latDistance / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($lonDistance / 2) * sin($lonDistance / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        return $earthRadius * $c;
    }
}
