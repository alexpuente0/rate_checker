require 'rate_checker'

RSpec.describe RateChecker::Rates do
  describe '.get' do
    let(:credentials) do
      { key: 'FEDEX_KEY', password: 'FEDEX_PASSWORD', account_number: 'FEDEX_ACCOUNT_NUMBER',
        meter_number: 'fedex_meter_number' }
    end
    let(:quote_params) do
      { shipper: { city: 'Sender City', postal_code: '12345', country_code: 'US' },
        recipient: { city: 'Receiver City', postal_code: '64340', country_code: 'MX' },
        package: { weight: 10, dimensions: [10, 10, 10] } }
    end

    before do
      allow(RateChecker::XMLHelper).to receive(:new).and_return(double(call: 'XML_PAYLOAD'))
    end

    context 'when API returns valid rate details' do
      let(:response_xml) do
        <<-XML
          <?xml version="1.0"?>
          <RateReply>
            <RateReplyDetails>
              <ServiceType>FEDEX_GROUND</ServiceType>
              <RatedShipmentDetails>
                <ShipmentRateDetail>
                  <CurrencyExchangeRate>
                    <Rate>1.0</Rate>
                  </CurrencyExchangeRate>
                  <TotalNetChargeWithDutiesAndTaxes>
                    <Amount>10.0</Amount>
                  </TotalNetChargeWithDutiesAndTaxes>
                </ShipmentRateDetail>
              </RatedShipmentDetails>
            </RateReplyDetails>
          </RateReply>
        XML
      end

      before do
        allow(Net::HTTP).to receive(:post).and_return(double(code: '200', is_a?: true, body: response_xml))
        allow(Nokogiri::XML).to receive(:parse).and_return(double(to_s: response_xml))
        allow(Hash).to receive(:from_xml).and_return('RateReply' => {
                                                       'RateReplyDetails' => [{
                                                         'ServiceType' => 'FEDEX_GROUND',
                                                         'RatedShipmentDetails' => [{
                                                           'ShipmentRateDetail' => {
                                                             'CurrencyExchangeRate' => { 'Rate' => '1.0' },
                                                             'TotalNetChargeWithDutiesAndTaxes' => { 'Amount' => '10.0' }
                                                           }
                                                         }]
                                                       }]
                                                     })
      end

      it 'returns an array of rate details' do
        rates = RateChecker::Rates.get(credentials, quote_params)
        p rates
        expect(rates).to be_an(Array)
        expect(rates.size).to eq(1)
        expect(rates[0]).to be_a(Hash)
        expect(rates[0]).to have_key(:price)
        expect(rates[0]).to have_key(:currency)
        expect(rates[0]).to have_key(:service_level)
      end
    end

    context 'when API returns an error' do
      before do
        allow(Net::HTTP).to receive(:post).and_return(double(code: '500', is_a?: true, body: nil))
      end

      it 'raises an exception with the error message' do
        expect { RateChecker::Rates.get(credentials, quote_params) }.to raise_error(StandardError)
      end
    end
  end
end
