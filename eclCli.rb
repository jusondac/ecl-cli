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
		byebug
	end
end



attempt = Attempt.new(mechanize:Mechanize.new, prompt: TTY::Prompt.new)
attempt.connect
attempt.do_your_job
