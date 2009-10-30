
require 'net/smtp'
require 'time'

Loquacious.remove :file

module Bones::Plugins::Ann
  include ::Bones::Helpers
  extend self

  def initialize_ann
    ::Bones.config {
      ann  {
        file  'announcement.txt'
        text  nil
        paragraphs  []
        email {
          from      nil
          to        %w(ruby-talk@ruby-lang.org)
          server    'localhost'
          port      25
          domain    ENV['HOSTNAME']
          acct      nil
          passwd    nil
          authtype  :plain
        }
      }
    }
  end

  def post_load
    config = ::Bones.config
    config.exclude << "^#{Regexp.escape(config.ann.file)}$"
  end

  def define_tasks
    config = ::Bones.config
    namespace :ann do

      # A prerequisites task that all other tasks depend upon
      task :prereqs

      file config.ann.file do
        ann = config.ann
        puts "Generating #{ann.file}"
        File.open(ann.file,'w') do |fd|
          fd.puts("#{config.name} version #{config.version}")
          fd.puts("    by #{Array(config.authors).first}") if config.authors
          fd.puts("    #{config.url}") if config.url.valid?
          fd.puts("    (the \"#{config.release_name}\" release)") if config.release_name
          fd.puts
          fd.puts("== DESCRIPTION")
          fd.puts
          fd.puts(config.description)
          fd.puts
          fd.puts(config.changes.sub(%r/^.*$/, '== CHANGES'))
          fd.puts
          ann.paragraphs.each do |p|
            fd.puts "== #{p.upcase}"
            fd.puts
            fd.puts paragraphs_of(config.readme_file, p).join("\n\n")
            fd.puts
          end
          fd.puts ann.text if ann.text
        end
      end

      desc "Create an announcement file"
      task :announcement => ['ann:prereqs', config.ann.file]

      desc "Send an email announcement"
      task :email => ['ann:prereqs', config.ann.file] do
        ann = config.ann
        from = ann.email[:from] || Array(config.authors).first || config.email
        to   = Array(ann.email[:to])

        ### build a mail header for RFC 822
        rfc822msg =  "From: #{from}\n"
        rfc822msg << "To: #{to.join(',')}\n"
        rfc822msg << "Subject: [ANN] #{config.name} #{config.version}"
        rfc822msg << " (#{config.release_name})" if config.release_name
        rfc822msg << "\n"
        rfc822msg << "Date: #{Time.new.rfc822}\n"
        rfc822msg << "Message-Id: "
        rfc822msg << "<#{"%.8f" % Time.now.to_f}@#{ann.email[:domain]}>\n\n"
        rfc822msg << File.read(ann.file)

        params = [:server, :port, :domain, :acct, :passwd, :authtype].map do |key|
          ann.email[key]
        end

        params[3] = config.email if params[3].nil?

        if params[4].nil?
          STDOUT.write "Please enter your e-mail password (#{params[3]}): "
          params[4] = STDIN.gets.chomp
        end

        ### send email
        Net::SMTP.start(*params) {|smtp| smtp.sendmail(rfc822msg, from, to)}
      end
    end  # namespace :ann

    desc 'Alias to ann:announcement'
    task :ann => 'ann:announcement'

    CLOBBER << config.ann.file
  end

end  # module Bones::Plugins::Ann

# EOF
