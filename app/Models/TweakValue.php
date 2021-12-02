<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;

class TweakValue extends Model
{
    use HasFactory;
    use Cachable;

    protected $guarded = ['id'];
    protected $connection = 'mysql2';

    public function tweakGroup()
    {
        return $this->belongsTo(TweakGroup::class);
    }
}
