require_relative 'rate_checker/version'
require_relative 'rate_checker/xml_helper'
require 'net/http'
require 'nokogiri'

module RateChecker
  class Rates
    URL = 'https://wsbeta.fedex.com:443/xml'.freeze

    # Metodo para obtener las tarifas de envio de FedEx por medio de su API
    def self.get(credentials, quote_params)
      # Crear los parámetros XML necesarios para la cotización del envío
      params = RateChecker::XMLHelper.new(credentials, quote_params)

      # Enviar la solicitud a la API de FedEx
      response = Hash.from_xml(Nokogiri::XML(remote_data(params.call)).to_s)['RateReply']

      # Revizar si la respuesta es válida y si no, arrojar un error
      unless response['RateReplyDetails']
        raise "#{response['Notifications']['Severity'].to_s.downcase.capitalize}: #{response['Notifications']['Message']}"
      end

      # Construir el array de hashes con las tarifas
      response['RateReplyDetails'].map { |rate| build_rate(rate) }.compact
    end

    # Metodo para mandar una solicitud HTTP POST a la API de FedEx
    def self.remote_data(url_params)
      # Crear la solicitud HTTP POST a la API de FedEx con los parámetros XML
      request = Net::HTTP.post(URI(URL), url_params, 'Content-Type' => 'application/xml')

      # verificar que la respuesta sea válida y si no, arrojar un error
      unless request.is_a?(Net::HTTPSuccess) && request.body
        raise "Fedex server answered with code: #{request.code} instead of 200"
      end

      # Devolver la respuesta de la API de FedEx (Body)
      request.body
    end

    # Metodo para construir el hash de detalles de tarifa basado en la respuesta de la API de FedEx
    def self.build_rate(rate)
      # Obtener el nombre del servicio y el precio
      service_type = rate['ServiceType']
      name = service_type.split('_').map(&:capitalize).join(' ')

      # Obtener el precio de la tarifa (se inicializa en 0 por default)
      price = 0

      # Iterar sobre los detalles de la tarifa y obtener el precio del envío
      rate['RatedShipmentDetails'].each do |detail|
        next if detail['ShipmentRateDetail']['CurrencyExchangeRate']['Rate'] != '1.0'

        price = detail['ShipmentRateDetail']['TotalNetChargeWithDutiesAndTaxes']['Amount'].to_f
      end

      # Armamos el hash con los detalles de la tarifa, si el precio es mayor a 0. Si no, devolvemos nil
      price.positive? ? { price:, currency: 'MXN', service_level: { name:, token: service_type } } : nil
    end
  end
end
