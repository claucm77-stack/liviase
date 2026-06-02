<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('microbusinesses', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('category')->nullable();
            $table->string('address')->nullable();
            $table->decimal('latitude', 10, 7)->default(4.7110000);
            $table->decimal('longitude', 10, 7)->default(-74.0721000);
            $table->text('maps_url')->nullable();
            $table->text('image_url')->nullable();
            $table->string('owner_id')->nullable();
            $table->string('contact')->nullable();
            $table->string('schedule')->nullable();
            $table->string('status')->default('activo');
            $table->timestamp('created_on_app_at')->nullable();
            $table->json('favorites')->nullable();
            $table->decimal('average_rating', 3, 2)->nullable();
            $table->unsignedInteger('ratings_count')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('microbusinesses');
    }
};
