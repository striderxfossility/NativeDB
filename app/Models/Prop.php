<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Type;
use App\Models\Bitfield;
use App\Models\Enum;
use App\Models\Code;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;
use Awobaz\Compoships\Compoships;

class Prop extends Model
{
    use HasFactory;
    use Cachable;
    use Compoships;

    protected $with = ['type'];

    public function type()
    {
        return $this->belongsTo(Type::class);
    }

    public function returnType()
    {
        return $this->belongsTo(Type::class, 'return_type');
    }

    public function returnBitfield()
    {
        return $this->belongsTo(Bitfield::class, 'return_bitfield');
    }

    public function returnEnum()
    {
        return $this->belongsTo(Enum::class, 'return_enum');
    }

    public function code()
    {
        return $this->belongsTo(Code::class, ['name', 'type_name'], ['prop', 'type']);
    }

    public function getReturnTypeNiceAttribute()
    {
        if($this->returnType != null)
            return '<<a class="text-pink-600 hover:text-pink-300" href="/classes/' . $this->returnType->id . '/show">' . $this->returnType->name . '</a>>';

        if($this->returnEnum != null)
            return '<<a class="text-purple-600 hover:text-purple-300" href="/enums/' . $this->returnEnum->id . '/show">' . $this->returnEnum->name . '</a>>';

        if($this->returnBitfield != null)
            return '<<a class="text-yellow-600 hover:text-yellow-300" href="/bitfields/' . $this->returnBitfield->id . '/show">' . $this->returnBitfield->name . '</a>>';
        
        return '';
    }

    public function getReturnNiceAttribute()
    {
        $replace = '<span class="text-green-700">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                            </svg> Array :
                        </span>';
                    
        

        $strBuilder = $this->return;

        $strBuilder = str_replace("array:", $replace, $strBuilder);

        $strBuilder = str_replace(':' . $this->returnType?->name, '', $strBuilder);
        $strBuilder = str_replace($this->returnType?->name, '', $strBuilder);

        $strBuilder = str_replace(':' . $this->returnEnum?->name, '', $strBuilder);
        $strBuilder = str_replace($this->returnEnum?->name, '', $strBuilder);

        $strBuilder = str_replace(':' . $this->returnBitfield?->name, '', $strBuilder);
        $strBuilder = str_replace($this->returnBitfield?->name, '', $strBuilder);

        return $strBuilder;
    }
}
