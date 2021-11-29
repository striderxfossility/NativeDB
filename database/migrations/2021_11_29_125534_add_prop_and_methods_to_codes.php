<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddPropAndMethodsToCodes extends Migration
{
    protected $connection = 'mysql2';

    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (Schema::connection('mysql2')->hasColumn('prop', 'method')) {
            Schema::connection('mysql2')->table('codes', function (Blueprint $table) {
                $table->string('prop')->after('type');
                $table->string('method')->after('prop');
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::connection('mysql2')->table('codes', function (Blueprint $table) {
            $table->dropColumn('prop');
            $table->dropColumn('method');
        });
    }
}
