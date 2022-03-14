require 'byebug'
require 'mechanize'
require 'awesome_print'
require 'tty-prompt'
mechanize = Mechanize.new
prompt = TTY::Prompt.new

class Attempt
	STRING_NOT_REQUIRED = ['Profile','Logout','To Do','Library','List Exam Susulan','Recap of Assessment','Kesehatan','Mobile Apps','Lihat Semua','selengkapnya','Download','Contact Us','PDF','Lihat semua','Form Verifikasi Kesehatan','Archived Course','My Course','Ini adalah sample file PDF']
	attr_accessor :login_link
	attr_accessor :mechanize
	attr_accessor :prompt
	attr_accessor :res
	attr_accessor :link
	attr_accessor :links_uri
	attr_accessor :course_lists

	def initialize(mechanize:, prompt:)
		self.mechanize = mechanize
		self.prompt = prompt
	end

	def connect
		self.login_link = getConnectLoginPage(self.prompt)
		res = self.mechanize.get self.login_link
		res = self.mechanize.get self.login_link
		self.res = loginSession(res.form,self.mechanize, self.prompt)
		sendListed(self.res)
	end

	def loginSession(form,mc,pr)
		puts "**Trying to Login"
		username, password = getUsernameAndPassword(pr)
		form.field_with(id:'username').value = username
		form.field_with(id:'password').value = password
		res = form.submit
	end

	def getUsernameAndPassword(pr)
		username = getInput(pr,'username')
		password = getInput(pr,'password','hide')
		[username, password]
	end

	def sendListed(res)
		link = getLink(res)
		title = getTitle(res)
		self.course_lists = Hash[[link,title].transpose]
		self.course_lists
	end

	def getLink(res)
		link = res.links.map{|x| x.uri}.compact
		link.reject!{|x| x.class.eql?(URI::Generic)}
		link.map!{|x| x.to_s[/\w+.+course\/detail\/\d+/] }
		link.compact!.uniq!
	end

	def getTitle(res)
		title = res.links.map{|x| x.to_s }
		title.map!{|x| x.strip }
		title.reject!{|x| Attempt::STRING_NOT_REQUIRED.include?(x) }
		title.reject!(&:empty?)
		title = title.each_slice(4).to_a
		title
	end

	def getInput(pr,str,*argv)
		argv.empty? ? pr.ask("#{str}: ") : pr.mask("#{str}: ")
	end

	def getConnectLoginPage(pr)
		puts "**Trying To Connect"
		login = pr.ask("[?] Input login Page", default:"https://ecl.teknik.unpas.ac.id")
		login
	end

	def do_your_job
		course_listed = self.course_lists.map{|k,v| v[0][/[\s][A-Za-z]+\s\w+.\w+/]}
		choice = selection(course_listed)
		link = ''
		self.course_lists.each do |k, v|
			v[0].include?(choice) ? link = k : ''
		end
		puts "Sepertinya sudah absen, semoga harimu menyenangkan!"
		links = self.mechanize.get link
		link_meet = links.links.map{|x| x.uri.to_s[/\w+.+course\/section\/\d+/]}.compact
		link_title = links.links.map{|x| x.to_s.strip[/Pertemuan.\d+/]}.compact
		get = {}
		link_title.each_with_index {|x,i| get[x] = link_meet[i] }
		choice = selection(get.map{|k,v| k}.to_a)
		puts get[choice]
		if get[choice].nil?
			puts "Sepertinya belum ada absen untuk Pertemuan kali ini"
		else
			byebug
		end
		puts "still running"
		exit!
	end

	def selection(arr)
		choice = self.prompt.select("choice course to attent", arr)
		choice.strip
	end
end

attempt = Attempt.new(mechanize:Mechanize.new, prompt: TTY::Prompt.new)
attempt.connect
attempt.do_your_job
