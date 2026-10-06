<?php

declare(strict_types=1);

namespace SmartChildHub\Core;

/**
 * Tiny front-controller style router.
 *
 * Route patterns support positional placeholders:  {id}  matches one segment.
 * Controllers are resolved against the PSR-4 autoloader at dispatch time.
 */
final class Router
{
    /** @var array<string, array<int, array{string, string|callable, string}>> */
    private array $routes = [
        'GET'     => [],
        'POST'    => [],
        'PUT'     => [],
        'PATCH'   => [],
        'DELETE'  => [],
        'OPTIONS' => [],
    ];

    /**
     * @param class-string|callable $controller
     */
    public function add(string $method, string $pattern, string|callable $controller, ?string $action = null): void
    {
        $regex = '#^' . preg_replace('/\{[^}]+\}/', '([^/]+)', trim($pattern, '/')) . '$#';
        $this->routes[strtoupper($method)][] = [$regex, $controller, $action];
    }

    public function get(string $pattern, string|callable $controller, ?string $action = null): void
    {
        $this->add('GET', $pattern, $controller, $action);
    }

    public function post(string $pattern, string|callable $controller, ?string $action = null): void
    {
        $this->add('POST', $pattern, $controller, $action);
    }

    public function put(string $pattern, string|callable $controller, ?string $action = null): void
    {
        $this->add('PUT', $pattern, $controller, $action);
    }

    public function delete(string $pattern, string|callable $controller, ?string $action = null): void
    {
        $this->add('DELETE', $pattern, $controller, $action);
    }

    public function dispatch(Request $request): void
    {
        $method = strtoupper($request->method());

        if ($method === 'OPTIONS') {
            Response::noContent('Preflight OK');
        }

        $path = trim($request->path(), '/');

        foreach ($this->routes[$method] ?? [] as [$regex, $controller, $action]) {
            if (preg_match($regex, $path)) {
                if (is_callable($controller)) {
                    $controller($request);
                    return;
                }
                /** @var Controller $instance */
                $instance = new $controller();
                $instance->{$action}($request);
                return;
            }
        }

        Response::error('Route not found.', 404);
    }
}
