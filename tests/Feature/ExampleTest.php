<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_redirects_guests_to_login(): void
    {
        $response = $this->get('/');

        $response->assertRedirect(route('login'));
    }

    public function test_privacy_policy_is_publicly_available(): void
    {
        $response = $this->get('/politica-privacidad-liviase.html');

        $response->assertOk();
        $response->assertSee('Política de privacidad de Livi@se');
    }
}
