namespace :acgt do
  task :create_services, [:url_name] => :environment do |_t, args|
    include Rails.application.routes.url_helpers

    facility = Facility.find_by!(url_name: args[:url_name])

    opts = { facility: facility,
             note_available_to_users: true,
             is_hidden: true,
             initial_order_status: OrderStatus.new_status,
             facility_account: facility.facility_accounts.active.first,
             account: "75340" }

    facility.transaction do
      service1 = Service.create!(opts.merge(name: "Sequencing - Low Cost",
                                            url_name: "low-cost-sequencing", acgt_service_type: "lowcost"))
      ExternalServicePasser.create!(active: true, passer: service1,
                                    external_service: UrlService.create!(location: new_sanger_sequencing_submission_url))

      service1 = Service.create!(opts.merge(name: "Sequencing - Standard",
                                            url_name: "standard-sequencing", acgt_service_type: "standard"))
      ExternalServicePasser.create!(active: true, passer: service1,
                                    external_service: UrlService.create!(location: new_sanger_sequencing_submission_url))

      service1 = Service.create!(opts.merge(name: "Sequencing - Premium",
                                            url_name: "premium-sequencing", acgt_service_type: "premium"))
      ExternalServicePasser.create!(active: true, passer: service1,
                                    external_service: UrlService.create!(location: new_sanger_sequencing_submission_url))

      puts "The services still require pricing and to have their hidden setting turned
        off before they are usable."
    end
  end
end
