module StripePayment

    class MakeStripePayment

        def initialize()
            @key = Rails.application.credentials.stripe[:secret_key]
        end

        def launchSession
            Stripe.api_key = @key
            session = Stripe::Checkout::Session.create(
                success_url: 'http://localhost:3000',
                cancel_url: 'http://localhost:3000',
                payment_method_types: ['card'],
                mode: 'subscription',
                line_items: [{
                    quantity: 1,
                    price: '300'
                }]
            )
        end

    end
    
end