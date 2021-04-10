module EmailVerification
    class Verify
        def initialize(email)
            @email = email
            @token = "e0f2e9ad55e52558f7c37c7603ab17db02702d911e4cf504887b1e1dc795" #Rails.application.credentials.emailverification['key']
        end

        def go 
          client = QuickEmailVerification::Client.new(@token)
          quickemailverification  = client.quickemailverification()
          response = quickemailverification.verify(@email)
          puts response.body['result']
          [false, "not verified"]
          if response.body['result'] == "valid"
            [true, {
              reason: response.body['reason'],
              mx_record: response.body['mx_record'],
              mx_domain: response.body['mx_domain']
            }]
          else
            [false, {
              reason: response.body['reason'],
              mx_record: response.body['mx_record'],
              mx_domain: response.body['mx_domain']
            }]
          end
        end
    end
    
end