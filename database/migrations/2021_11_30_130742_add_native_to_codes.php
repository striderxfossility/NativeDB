<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddNativeToCodes extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (!Schema::connection('mysql2')->hasColumn('codes', 'native')) {
            Schema::connection('mysql2')->table('codes', function (Blueprint $table) {
                $table->text('native')->after('code');
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
        if (Schema::connection('mysql2')->hasColumn('codes', 'native')) {
            Schema::connection('mysql2')->table('codes', function (Blueprint $table) {
                $table->dropColumn('native');
            });
        }
    }
}
