<?php

namespace App\Http;

use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
    /**
     * The application's global HTTP middleware stack.
     *
     * These middleware are run during every request to your application.
     *
     * @var array
     */
    protected $middleware = [
        // Handles trusted proxies and sets headers accordingly
        \App\Http\Middleware\TrustHosts::class,

        // Sets trusted proxies for the application
        \App\Http\Middleware\TrustProxies::class,

        // Handles Cross-Origin Resource Sharing (CORS) settings
        \Illuminate\Http\Middleware\HandleCors::class,

        // Prevents requests when the application is in maintenance mode
        \App\Http\Middleware\PreventRequestsDuringMaintenance::class,

        // Validates the maximum size of POST requests
        \Illuminate\Foundation\Http\Middleware\ValidatePostSize::class,

        // Trims whitespace from request data
        \App\Http\Middleware\TrimStrings::class,

        // Converts empty strings in request data to null
        \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
    ];

    /**
     * The application's route middleware groups.
     *
     * @var array
     */
    protected $middlewareGroups = [
        /**
         * The "web" middleware group applies to routes that require session state,
         * CSRF protection, and other web-related features.
         */
        'web' => [
            // Encrypts cookies before sending them to the client
            \App\Http\Middleware\EncryptCookies::class,

            // Adds queued cookies to the response
            \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,

            // Starts the session for the request
            \Illuminate\Session\Middleware\StartSession::class,

            // Shares errors from the session to the views
            \Illuminate\View\Middleware\ShareErrorsFromSession::class,

            // Verifies the CSRF token on POST, PUT, DELETE requests
            \App\Http\Middleware\VerifyCsrfToken::class,

            // Substitutes route bindings and resolves route model bindings
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],

        /**
         * The "api" middleware group applies to API routes, typically stateless,
         * and often used with token-based authentication.
         */
        'api' => [
            // Ensures frontend requests are stateful when using Laravel Sanctum
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,

            // Limits the number of requests to prevent abuse (throttling)
            'throttle:api',

            // Substitutes route bindings and resolves route model bindings
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
    ];

    /**
     * The application's route middleware.
     *
     * These middleware may be assigned to groups or used individually.
     *
     * @var array
     */
    protected $routeMiddleware = [
        // Enforces user authentication
        'auth' => \App\Http\Middleware\Authenticate::class,

        // Enforces HTTP Basic Authentication
        'auth.basic' => \Illuminate\Auth\Middleware\AuthenticateWithBasicAuth::class,

        // Authenticates the session
        'auth.session' => \Illuminate\Session\Middleware\AuthenticateSession::class,

        // Sets cache headers on responses
        'cache.headers' => \Illuminate\Http\Middleware\SetCacheHeaders::class,

        // Authorizes user actions based on policies
        'can' => \Illuminate\Auth\Middleware\Authorize::class,

        // Redirects authenticated users to a different page
        'guest' => \App\Http\Middleware\RedirectIfAuthenticated::class,

        // Requires the user to confirm their password
        'password.confirm' => \Illuminate\Auth\Middleware\RequirePassword::class,

        // Validates signed URLs
        'signed' => \Illuminate\Routing\Middleware\ValidateSignature::class,

        // Limits the rate of incoming requests
        'throttle' => \Illuminate\Routing\Middleware\ThrottleRequests::class,

        // Ensures the user's email is verified
        'verified' => \Illuminate\Auth\Middleware\EnsureEmailIsVerified::class,

        // Custom alias for Sanctum's stateful authentication
        'auth:sanctum' => \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    ];
}
