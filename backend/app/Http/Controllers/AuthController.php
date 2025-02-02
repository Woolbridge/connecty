<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;



class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name'     => 'required|string',
            'email'    => 'required|email|unique:users',
            'password' => 'required|min:8',
        ]);

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Create initial profile entry
        $user->profile()->create([]);

        return response()->json(['user' => $user], 201);
    }

    public function login(Request $request)
    {
        // Validate the request input
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required|min:6',
        ]);

        // If validation fails, return an error response
        if ($validator->fails()) {
            return response()->json(['message' => $validator->errors()], 422);
        }

        // Find user by email
        $user = User::where('email', $request->email)->first();

        // Check if user exists and password is correct
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        // Create token for the authenticated user
        $token = $user->createToken('authToken')->plainTextToken;
        try {
            // Code that might fail
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
        /*if ($token==NULL or $token=="") {
            return response()->json(['message' => 'error logging in because of token creation '], 540);}*/

        // Return the token and user details in the response
        return response()->json([
            'message'=>'login successful',
            'token' => $token,
            'user' => $user
        ], 200);
    }
}
