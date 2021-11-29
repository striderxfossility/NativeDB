<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;
use Awobaz\Compoships\Compoships;

class Code extends Model
{
    use HasFactory;
    use Cachable;
    use Compoships;

    protected $guarded = ['id'];
    protected $connection = 'mysql2';
}
