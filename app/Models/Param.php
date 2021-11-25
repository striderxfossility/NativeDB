<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Method;
use App\Models\Type;

class Param extends Model
{
    use HasFactory;

    public function method()
    {
        return $this->belongsTo(Method::class);
    }

    public function typeHead()
    {
        return $this->belongsTo(Type::class, 'type_id');
    }
}
