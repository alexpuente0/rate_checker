module RateChecker
  class XMLHelper
    def initialize(credentials, quote_params)
      @credentials = credentials
      @quote_params = quote_params
    end

    # Este método genera el XML que representa la solicitud a la API FedEx.
    # Se integra con los metodos que manejan las credenciales de autenticación,
    # información de la cuenta del cliente, detalles de origen y destino, y
    # detalles del paquete a enviar.
    def call
      <<~XML
        <RateRequest xmlns="http://fedex.com/ws/rate/v13">
          #{access_keys}
          <Version>
            <ServiceId>crs</ServiceId>
            <Major>13</Major>
            <Intermediate>0</Intermediate>
            <Minor>0</Minor>
          </Version>
          <ReturnTransitAndCommit>true</ReturnTransitAndCommit>
          <RequestedShipment>
            <DropoffType>REGULAR_PICKUP</DropoffType>
            <PackagingType>YOUR_PACKAGING</PackagingType>
            #{origin}
            #{destination}
            <ShippingChargesPayment>
              <PaymentType>SENDER</PaymentType>
            </ShippingChargesPayment>
            <RateRequestTypes>ACCOUNT</RateRequestTypes>
            <PackageCount>1</PackageCount>
            <RequestedPackageLineItems>
              <GroupPackageCount>1</GroupPackageCount>
              #{box_weight}
              #{box_size}
            </RequestedPackageLineItems>
          </RequestedShipment>
        </RateRequest>
      XML
    end

    # Este método arma la parte del XML con las credenciales de autenticación del cliente,
    # incluyendo Key, Password, Número de cuenta y Numero de Meter.
    def access_keys
      <<~XML
        <WebAuthenticationDetail>
          <UserCredential>
            <Key>#{@credentials[:key]}</Key>
            <Password>#{@credentials[:password]}</Password>
          </UserCredential>
        </WebAuthenticationDetail>
        <ClientDetail>
          <AccountNumber>#{@credentials[:account_number]}</AccountNumber>
          <MeterNumber>#{@credentials[:meter_number]}</MeterNumber>
          <Localization>
            <LanguageCode>es</LanguageCode>
            <LocaleCode>mx</LocaleCode>
          </Localization>
        </ClientDetail>
      XML
    end

    # Estos métodos conforman la parte del XML con los datos de origen y destino del envío.
    def origin
      <<~XML
        <Shipper>
          <Address>
            <StreetLines></StreetLines>
            <City></City>
            <StateOrProvinceCode>XX</StateOrProvinceCode>
            <PostalCode>#{@quote_params[:address_from][:zip]}</PostalCode>
            <CountryCode>#{@quote_params[:address_from][:country].upcase}</CountryCode>
          </Address>
        </Shipper>
      XML
    end

    def destination
      <<~XML
        <Recipient>
          <Address>
            <StreetLines></StreetLines>
            <City></City>
            <StateOrProvinceCode>XX</StateOrProvinceCode>
            <PostalCode>#{@quote_params[:address_to][:zip]}</PostalCode>
            <CountryCode>#{@quote_params[:address_to][:country].upcase}</CountryCode>
            <Residential>false</Residential>
          </Address>
        </Recipient>
      XML
    end

    # Estos métodos conforman la parte del XML con los datos fisicos del paquete a enviar.
    def box_weight
      <<~XML
        <Weight>
          <Units>#{@quote_params[:parcel][:mass_unit].upcase}</Units>
          <Value>#{@quote_params[:parcel][:weight].round}</Value>
        </Weight>
      XML
    end

    def box_size
      <<~XML
                <Dimensions>
                  <Length>#{@quote_params[:parcel][:length].round}</Length>
                  <Width>#{@quote_params[:parcel][:width].round}</Width>
                  <Height>#{@quote_params[:parcel][:height].round}</Height>
                  <Units>#{@quote_params[:parcel][:dimension_unit].upcase}</Units>
        </Dimensions>
      XML
    end
  end
end
