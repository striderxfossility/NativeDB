<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMethodsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('methods', function (Blueprint $table) {
            $table->id();
            $table->integer('type_id');
            $table->string('type_name');
            $table->string('fullName');
            $table->string('shortName');
            $table->text('params');
            $table->string('return');
            $table->integer('return_flags');
            $table->integer('return_type');
            $table->integer('return_enum');
            $table->integer('return_bitfield');
            $table->integer('flags');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('methods');
    }
}
