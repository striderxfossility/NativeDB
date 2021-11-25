<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Type;
use App\Models\Param;

class Method extends Model
{
    use HasFactory;

    public function type()
    {
        return $this->belongsTo(Type::class);
    }

    public function returnType()
    {
        return $this->belongsTo(Type::class, 'return_type');
    }

    public function paramsArr()
    {
        return $this->hasMany(Param::class);
    }

    public function getReturnNiceAttribute()
    {
        $strBuilder = '';

        if($this->return == '') {
            $strBuilder .= '<div class="text-yellow-700">';
            $strBuilder .= '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">';
            $strBuilder .= '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />';
            $strBuilder .= '</svg>'; 
            $strBuilder .= 'void';
            $strBuilder .= '</div>';
        } else {
            $strBuilder .= 'return : ';
        }
        
        if(str_contains($this->return, 'array')) {

            $strBuilder .= '<span class="text-green-700">';
            $strBuilder .= '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">';
            $strBuilder .= '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />';
            $strBuilder .= '</svg>';
            $strBuilder .= explode(':', $this->return)[0] . '</span> : ';

                if(explode(':', $this->return)[1] == 'handle') {
                    $strBuilder .= '<span class="text-pink-600">';
                    $strBuilder .= explode(':', $this->return)[1];
                    $strBuilder .= '</span>';
                } else {
                    $strBuilder .= explode(':', $this->return)[1];
                }
        } elseif(str_contains($this->return, 'handle')) {
            $strBuilder .= '<span class="text-pink-600">';
            $strBuilder .= explode(':', $this->return)[0];
            $strBuilder .= '</span>';
        } else {
            $strBuilder .= $this->return;
        }

        return $strBuilder;
    }

    public function getReturnTypeNiceAttribute()
    {
        if($this->returnType == null)
            return '';

        return '<<a class="text-pink-600 hover:text-pink-300" href="/classes/' . $this->returnType->id . '/show">' . $this->returnType->name . '</a>>';
    }
    
    public function getFunctionNiceAttribute()
    {
        $strBuilder = '';

        if($this->params == '') {
            return $this->shortName . '()';
        } else {
            $strBuilder .= $this->shortName . '(<br />';
            
            if($this->params != '')
            {
                $strBuilder .= '<div class="grid grid-cols-3 px-10">';
                    foreach($this->paramsArr as $param)
                    {

                        $strBuilder .= '<div>' . $param->name . '</div>';

                        if(str_contains($param->type, 'handle')) {
                            $typeBuild = '<a class="text-pink-600 hover:text-pink-300" href="/classes/' . $param->typeHead->id . '/show">' . $param->typeHead->name . '</a>';

                            $strBuilder .= '<div>' . explode(":", $param->type)[0] . ' &#60;' . $typeBuild . '&#62;</div>';
                        } else {
                            $strBuilder .= '<div>' . $param->type . '</div>';
                        }

                        $strBuilder .= '<div></div>';
                    }
                    $strBuilder .= '</div>';
            }

            $strBuilder .= ')';
        }

        return $strBuilder;
    }
}
