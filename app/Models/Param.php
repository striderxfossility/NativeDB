<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Method;

class Param extends Model
{
    use HasFactory;

    public function method()
    {
        return $this->belongsTo(Method::class);
    }
}
