class Mailer < ApplicationMailer
	include ApplicationHelper
	include SessionsHelper
	include EmployeesHelper

	default from: "bucks@hollywoodcasinotoledo.org"

	def mail_feedback(message, user)
		@from = user.full_name
		@message = message
		@roles = Role.where(feedback: true)
		@roles = @roles.map { |r| r.id }
		@jobcodes = Permission.where(role_id: @roles)
		@jobcodes = @jobcodes.map { |f| f.job_id }
		@recipients = Array.new
		@jobcodes.each do |f|
			Employee.where(job_id: f).where(status: "Active").each do |e|
				@recipients.push(e.email)
			end
		end

		mail(to: @recipients, subject: 'Feedback: ' + @from)
	end

	def mail_issue(message, url, user)
		@from = user.full_name
		@message = message
		@url = url
		@roles = Role.where(feedback: true)
		@roles = @roles.map { |r| r.id }
		@jobcodes = Permission.where(role_id: @roles)
		@jobcodes = @jobcodes.map { |f| f.job_id }
		@recipients = Array.new
		@jobcodes.each do |f|
			Employee.where(job_id: f).where(status: "Active").each do |e|
				@recipients.push(e.email)
			end
		end

		mail(to: @recipients, subject: 'Issue: ' + @from)
	end

	def notify_employee(buck, user)
		@user = user
		@buck = buck
		@issuer = Employee.find(buck.assignedBy)

		notification_params = { to_id: user.IDnum, 
			from_id: @issuer.IDnum, 
			read: false,
			target_id: @buck.number,
			category: Notification::NEW_BUCK }
		Notification.new(notification_params).save

		mail(to: user.email, subject: 'Buck Awarded!')
	end

	def notify_issuer(buck, issuer, employee, approver, decision, reason)
		@buck = buck
		@issuer = issuer
		@employee = employee
		@decision = decision
		@reason = reason

		if decision == 'Approved'
			notification_params = { to_id: issuer.IDnum, 
				from_id: approver.IDnum, 
				target_id: @buck.number,
				category: Notification::BUCK_APPROVED }
			Notification.new(notification_params).save
		else
			notification_params = { to_id: issuer.IDnum, 
				from_id: approver.IDnum, 
				target_id: @buck.number,
				category: Notification::BUCK_DENIED }
			Notification.new(notification_params).save
		end

		mail(to: @issuer.email, subject: 'Pending Buck Status')
	end

	def opt_in
		@user = Employee.find(params[:id])
		@user.update_attribute(:email, true)
		flash[:title] = 'Success'
		flash[:notice] = 'You will now receive email notifications from the bucks program!'
		redirect_to controller: :employee, action: :show, id: @current_user
	end

	def opt_out
		@user = Employee.find(params[:id])
		@user.update_attribute(:email, false)
		flash[:title] = 'Success'
		flash[:notice] = 'You will no longer receive email notifications from the bucks program.'
		redirect_to controller: :employee, action: :show, id: @current_user
	end


	def order_notify(prize, prize_subcat, user, quantity)
		@user = user
		@prize = prize
		@prize_subcat = prize_subcat
		@quantity = quantity

		mail(to: ['HWT.Wardrobe@pngaming.com', 'Paul.Rowden@pngaming.com', 'Amber.Ulrich@pngaming.com', 'jzermen@bgsu.edu'], subject: 'New Prize Order')
	end

	def pending_buck_approval(user, buck)
		# Function to notify designated approvers that a buck is requiring approval.
		# user - issuer
		@user = user
		@buck = buck
		@employee = Employee.find_by(IDnum: buck.employee_id)
		@url = 'http://bucks.hollywoodcasinotoledo.org/bucks/pending/' + buck.number.to_s
		@approver1 = Department.find(@employee.department_id).approve1
		@approver2 = Department.find(@employee.department_id).approve2

		@approvers = Array.new
		Employee.where(status: 'Active').where(job_id: @approver1).each do |e| 
			@approvers.push(e.email) if !e.nil?
			notification_params = { to_id: e.IDnum, 
				from_id: user.IDnum, 
				target_id: buck.number,
				category: Notification::PENDING_BUCK }
			Notification.new(notification_params).save
		end

		Employee.where(status: 'Active').where(job_id: @approver2).each do |e| 
			@approvers.push(e.email) if !e.nil? 
			notification_params = { to_id: e.IDnum, 
				from_id: user.IDnum, 
				target_id: buck.number,
				category: Notification::PENDING_BUCK }
			Notification.new(notification_params).save
		end

		mail(to: @approvers, subject: 'Buck Requiring Approval')
	end

end