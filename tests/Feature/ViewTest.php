<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Type;

class ViewTest extends TestCase
{
    /**
     * A basic feature test example.
     *
     * @return void
     */
    public function test_see_if_all_type_views_can_be_loaded()
    {
        foreach(Type::all() as $type)
        {
            if($type->cached) {
                fwrite(STDERR, print_r("Testing " . $type->name . "\n", TRUE));
                $this->get(route('types.show', $type))->assertStatus(200);
            } else {
                fwrite(STDERR, print_r($type->name . " NOT CACHED!\n", TRUE));
            }
        }
    }
}
