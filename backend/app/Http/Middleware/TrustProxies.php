<?php

namespace App\Http\Middleware;

use Illuminate\Http\Middleware\TrustProxies as Middleware;
use Illuminate\Http\Request ;

class TrustProxies extends Middleware
{
    /**
     * The trusted proxies for this application.
     *
     * You can set this to '*' to trust all proxies.
     *
     * @var array|string|null
     */
    protected $proxies = '*';

    /**
     * The headers that should be used to detect proxies.
     *
     * @var int
     */
      protected $headers = Request::HEADER_X_FORWARDED_FOR;
      /*protected $headers =
      SymfonyRequest::HEADER_X_FORWARDED_FOR |
      SymfonyRequest::HEADER_X_FORWARDED_HOST |
      SymfonyRequest::HEADER_X_FORWARDED_PORT |
      SymfonyRequest::HEADER_X_FORWARDED_PROTO |
      SymfonyRequest::HEADER_X_FORWARDED_AWS_ELB;*/

}
