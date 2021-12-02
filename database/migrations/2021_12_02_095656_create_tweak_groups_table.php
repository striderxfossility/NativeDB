<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTweakGroupsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if(!Schema::connection('mysql2')->hasTable('tweak_groups')) {
            Schema::connection('mysql2')->create('tweak_groups', function (Blueprint $table) {
                $table->id();
                $table->integer('tweak_group_id')->default(0);
                $table->string('name');
                $table->timestamps();
            });
        };
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::connection('mysql2')->dropIfExists('tweak_groups');
    }
}
