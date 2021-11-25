<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Member;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;

class Enum extends Model
{
    use HasFactory;
    use Cachable;
    
    public function members()
    {
        return $this->hasMany(Member::class);
    }
}
