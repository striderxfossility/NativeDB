<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Method;
use App\Models\Type;
use App\Models\Enum;
use App\Models\Bitfield;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;

class Param extends Model
{
    use HasFactory;
    use Cachable;

    public function method()
    {
        return $this->belongsTo(Method::class);
    }

    public function typeHead()
    {
        return $this->belongsTo(Type::class, 'type_id');
    }

    public function enumHead()
    {
        return $this->belongsTo(Enum::class, 'enum_id');
    }

    public function bitfieldHead()
    {
        return $this->belongsTo(Bitfield::class, 'bitfield_id');
    }
}
