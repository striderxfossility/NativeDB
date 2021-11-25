<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Enum;

class Member extends Model
{
    use HasFactory;

    public function enum()
    {
        return $this->belongsTo(Enum::class);
    }
}
