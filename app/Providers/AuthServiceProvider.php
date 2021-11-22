<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        //\App\Models\Model::class  => \App\Policies\ModelPolicy::class,
    ];

    public function boot()
    {
        $this->registerPolicies();
    }
}
