<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('contents', function (Blueprint $table) {
            $table->foreignId('content_category_id')
                ->nullable()
                ->after('type');

            $table->index('content_category_id');
            $table->foreign('content_category_id')
                ->references('id')
                ->on('content_categories')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('contents', function (Blueprint $table) {
            // Drop FK first (some DBs require it)
            $table->dropForeign(['content_category_id']);
            $table->dropIndex(['content_category_id']);
            $table->dropColumn('content_category_id');
        });
    }
};
