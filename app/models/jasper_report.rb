class JasperReport < ActiveRecord::Base
  # attr_accessible :title, :body

  def self.login
    RestClient.post(
      URI.join(JASPER_CONFIG[:url]+'/', 'rest/login').to_s,
      {
        j_username: JASPER_CONFIG[:username],
        j_password: JASPER_CONFIG[:password]
      }
    ).cookies
  end

  def self.run_report(cnf)
    pm = begin URI.encode_www_form(cnf[:params]).to_s rescue "" end
    RestClient.get(
      URI.join(JASPER_CONFIG[:url]+'/', "rest_v2/reports/#{cnf[:report]}.#{cnf[:format]}?#{pm}").to_s,
      {:cookies => self.login }
    )
  end

end
