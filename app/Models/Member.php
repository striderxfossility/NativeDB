<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Enum;
use App\Models\Bitfield;

class Member extends Model
{
    use HasFactory;

    public function enum()
    {
        return $this->belongsTo(Enum::class);
    }

    public function bitfield()
    {
        return $this->belongsTo(Bitfield::class);
    }
}
