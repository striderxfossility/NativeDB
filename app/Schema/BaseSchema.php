<?php

namespace App\Schema;

class BaseSchema
{
    public int      $headType;
    public string   $name;
    public string   $code = '';
    public array    $fields;
}