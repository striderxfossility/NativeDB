<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Type;
use App\Models\Param;
use App\Models\Enum;
use App\Models\Bitfield;
use App\Models\Code;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;
use Awobaz\Compoships\Compoships;

class Method extends Model
{
    use HasFactory;
    use Cachable;
    use Compoships;

    public function type()
    {
        return $this->belongsTo(Type::class);
    }

    public function returnType()
    {
        return $this->belongsTo(Type::class, 'return_type');
    }

    public function returnEnum()
    {
        return $this->belongsTo(Enum::class, 'return_enum');
    }

    public function returnBitfield()
    {
        return $this->belongsTo(Bitfield::class, 'return_bitfield');
    }

    public function paramsArr()
    {
        return $this->hasMany(Param::class);
    }

    public function code()
    {
        return $this->belongsTo(Code::class, ['shortName', 'type_name'], ['method', 'type']);
    }

    public function getReturnNiceAttribute()
    {
        $strBuilder = '';

        if($this->return == '') {
            $strBuilder .= '<div class="inline text-yellow-700">';
            $strBuilder .= '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">';
            $strBuilder .= '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />';
            $strBuilder .= '</svg>'; 
            $strBuilder .= ' void';
            $strBuilder .= '</div>';
        } else {
            $strBuilder .= '';
        }
        
        if(str_contains($this->return, 'array')) {

            $strBuilder .= '<span class="text-green-700 inline">';
            $strBuilder .= '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">';
            $strBuilder .= '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />';
            $strBuilder .= '</svg> ';
            $strBuilder .= explode(':', $this->return)[0] . '</span> : ';

                if(explode(':', $this->return)[1] == 'handle') {
                    $strBuilder .= '<span class="inline text-pink-600">';
                    $strBuilder .= explode(':', $this->return)[1];
                    $strBuilder .= '</span>';
                } else {
                    $strBuilder .= explode(':', $this->return)[1];
                }
        } elseif(str_contains($this->return, 'handle')) {
            $strBuilder .= '<span class="inline text-pink-600">';
            $strBuilder .= explode(':', $this->return)[0];
            $strBuilder .= '</span>';
        } else {
            $strBuilder .= $this->return;
        }

        return $strBuilder;
    }

    public function getReturnTypeNiceAttribute()
    {
        if($this->returnType != null)
            return ' <<a class="text-pink-600 hover:text-pink-300" href="/classes/' . $this->returnType->id . '/show">' . $this->returnType->name . '</a>>';
        
        if($this->returnEnum != null)
            return ' <<a class="text-purple-600 hover:text-purple-300" href="/enums/' . $this->returnEnum->id . '/show">' . $this->returnEnum->name . '</a>>';

        if($this->returnBitfield != null)
            return ' <<a class="text-yellow-600 hover:text-yellow-300" href="/bitfields/' . $this->returnBitfield->id . '/show">' . $this->returnBitfield->name . '</a>>';
        
            return '';
    }
    
    public function getFunctionNiceAttribute()
    {
        $strBuilder = '';

        if($this->params == '') {
            return $this->shortName . '() => ' . $this->returnNice . $this->returnTypeNice;
        } else {
            $strBuilder .= $this->shortName . ' (<br />';
            
            if($this->params != '')
            {
                $strBuilder .= '<div class="grid grid-cols-6 mx-10 p-2 w-screen">';
                    foreach($this->paramsArr as $param)
                    {

                        $strBuilder .= '<div><span class="text-red-400">param</span> ' . $param->name . '</div>';

                        if($param->typeHead != null) {
                            $typeBuild = '<a class="inline text-pink-600 hover:text-pink-300" href="/classes/' . $param->typeHead->id . '/show">' . $param->typeHead->name . '</a>';

                            $strBuilder .= '<div>' . explode(":", $param->type)[0] . '</div>';
                            $strBuilder .= '<div class="col-span-4">&#60;' . $typeBuild . '&#62</div>';
                        } elseif($param->enumHead != null) {
                            $enumBuild = '<a class="inline text-purple-600 hover:text-purple-300" href="/enums/' . $param->enumHead->id . '/show">' . $param->enumHead->name . '</a>';

                            $strBuilder .= '<div>' . explode(":", $param->enum)[0] . '</div>';
                            $strBuilder .= '<div class="col-span-4">&#60;' . $enumBuild . '&#62</div>';
                        } elseif($param->bitfieldHead != null) {
                            $bitfieldBuild = '<a class="inline text-yellow-600 hover:text-yellow-300" href="/bitfields/' . $param->bitfieldHead->id . '/show">' . $param->bitfieldHead->name . '</a>';

                            $strBuilder .= '<div>' . explode(":", $param->bitfield)[0] . '</div>';
                            $strBuilder .= '<div class="col-span-4">&#60;' . $bitfieldBuild . '&#62</div>';
                        } else {
                            $strBuilder .= '<div>' . $param->type . '</div>';
                            $strBuilder .= '<div class="col-span-4"></div>';
                        }
                    }
                $strBuilder .= '</div>';
            }

            $strBuilder .= ') => ' . $this->returnNice . $this->returnTypeNice;
        }

        return $strBuilder;
    }
}
