<?php

namespace App\Services;

use App\Models\Type;
use App\Models\Prop;
use App\Models\Enum;
use App\Models\Bitfield;
use App\Models\Method;
use App\Models\Param;

class ImportService 
{
    public static $chachedTypes = [];

    private static function getType(string $name) {
        if(isset(self::$chachedTypes[$name])) {
            return self::$chachedTypes[$name];
        }

        $type = Type::getType($name);

        self::$chachedTypes[$name] = $type;

        return $type;
    }

    private static function getEnum(string $name) {
        $enum = Enum::getEnum($name);

        return $enum;
    }

    private static function getBitfield(string $name) {
        $bitfield = Bitfield::getBitfield($name);

        return $bitfield;
    }

    public static function get(Type $type, array $chachedTypes = [], bool $returnArray = false) {

        self::$chachedTypes = $chachedTypes;

        if($type->cached)
            return $type;

        $jsonString = file_get_contents(base_path('public/dumps/classes/'. $type->name .'.json'));

        $data = json_decode($jsonString, true);
        $time = now()->toDateTimeString();

        if(isset($data['props'])) {
            foreach($data['props'] as $prop)
            {
                $explodeArr         = explode(":", $prop['type']);
                $return_type        = '';
                $return_enum        = '';
                $return_bitfield    = '';
                $return             = $prop['type'];

                foreach($explodeArr as $explode)
                {
                    $return_type = self::getType($explode);

                    if($return_type == 0)
                        $return_enum = self::getEnum($explode);

                    if($return_type == 0 && $return_enum == 0)
                        $return_bitfield = self::getBitfield($explode);
                }

                $dataProps[] = [
                    "type_id"           => $type->id,
                    "name"              => $prop['name'],
                    "return"            => $return,
                    "return_type"       => $return_type,
                    "return_enum"       => $return_enum,
                    "return_bitfield"   => $return_bitfield,
                    "flags"             => $prop['flags'],
                    'created_at'        => $time,
                    'updated_at'        => $time,
                ];
            }

            $chunks = array_chunk($dataProps, 1000);
            foreach($chunks as $chunk)
            {
                Prop::insert($chunk);
            }
        }

        if(isset($data['funcs'])) {
            foreach($data['funcs'] as $methods)
            {
                $return_type        = 0;
                $return_enum        = 0;
                $return_bitfield    = 0;

                if(isset($methods['return'])) {

                    $explodeArr = explode(":", $methods['return']['type']);

                    foreach($explodeArr as $explode)
                    {
                        $return_type = self::getType($explode);

                        if($return_type == 0)
                            $return_enum = self::getEnum($explode);

                        if($return_type == 0 && $return_enum == 0)
                            $return_bitfield = self::getBitfield($explode);
                    }
                }

                $dataMethods[] = [
                    "type_id"           => $type->id,
                    "fullName"          => $methods['fullName'],
                    "shortName"         => $methods['shortName'],
                    "return"            => isset($methods['return']) ? $methods['return']['type'] : '',
                    "return_flags"      => isset($methods['return']) ? $methods['return']['flags'] : '',
                    "return_type"       => $return_type,
                    "return_enum"       => $return_enum,
                    "return_bitfield"   => $return_bitfield,
                    "flags"             => $methods['flags'],
                    "params"            => isset($methods['params']) ? json_encode($methods['params']) : '',
                    'created_at'        => $time,
                    'updated_at'        => $time,
                ];
            }

            $chunks = array_chunk($dataMethods, 1000);
            foreach($chunks as $chunk)
            {
                Method::insert($chunk);
            }

            foreach(Method::whereTypeId($type->id)->get() as $method) 
            {
                if($method->params != "") {
                    $jsonArr = json_decode($method->params);

                    if($jsonArr != null) {
                        foreach ($jsonArr as $json)
                        {
                            $typeF = self::getType($json->type);

                            if(str_contains($json->type, ':')) {
                                $explodeArr = explode(':', $json->type);

                                foreach($explodeArr as $explode) 
                                {
                                    $typeF = self::getType($explode);
                                }
                            }

                            $dataParams[] = [
                                'method_id'     => $method->id,
                                'name'          => $json->name,
                                'flags'         => $json->flags,
                                'type'          => $json->type,
                                'type_id'       => $typeF,
                                'created_at'    => $time,
                                'updated_at'    => $time,
                            ];
                        }
                    }
                }
            }

            if(isset($dataParams)) {
                $chunks = array_chunk($dataParams, 1000);
                foreach($chunks as $chunk)
                {
                    Param::insert($chunk);
                }
            }
        }

        $type->type_id  = self::getType($type->parent);
        $type->cached   = true;

        $type->save();

        if($returnArray)
            return self::$chachedTypes;
        
        return $type;
    }
}