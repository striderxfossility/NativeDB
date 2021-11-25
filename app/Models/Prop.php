<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Type;

class Prop extends Model
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

    public function getReturnTypeNiceAttribute()
    {
        if($this->returnType == null)
            return '';

        return '<<a class="text-pink-600 hover:text-pink-300" href="/classes/' . $this->returnType->id . '/show">' . $this->returnType->name . '</a>>';
    }

    public function getReturnNiceAttribute()
    {
        if(str_contains($this->return, 'array')) {
            
            $strBuilder = '<span class="text-green-700">';

            $strBuilder .= '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                            </svg> ';

            $strBuilder .= explode(':', $this->return)[0] . '</span> : ';
                
            if(explode(':', $this->return)[1] == 'handle') {
                $strBuilder .= '<span class="text-pink-600">';
                $strBuilder .= explode(':', $this->return)[1] . '</span>';
            } else {
                $strBuilder .= explode(':', $this->return)[1];
            }

            return $strBuilder;

        } elseif($this->return == 'handle') {
            return 
            '<span class="text-pink-600">   
                ' . $this->return . '
            </span>';
        } 

        return $this->return;
    }
}
