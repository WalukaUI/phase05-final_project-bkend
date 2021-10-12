class PatientsController < ApplicationController
  before_action :authorize, only: [:show, :index]
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
   
    def index
      if params[:doctor_id]
        doctor = Doctor.find(params[:doctor_id])
        patient = doctor.patients
      else
        patient=Patient.all
      end
        render json: patient.to_json(except: [:created_at, :updated_at, :username,:password_digest])
    end
    
    def create
     patient = Patient.create(patient_params)
       if patient.valid?
         session[:user_id] = patient.id
         render json: patient.to_json(except: [:created_at, :updated_at, :password_digest]), status: :created
       else
         render json: { error: patient.errors.full_messages }, status: :unprocessable_entity
       end
    end

    def update
      patient = Patient.find(params[:id])
      patient.update!(patient_params)
      render json: patient.to_json(except: [:created_at, :updated_at, :password_digest])
    end

    def destroy
      patient = Patient.destroy(params[:id])
      render json: {message: "Patient deleted"}
    end

    def show
      patient = Patient.find_by(id: session[:user_id])
      render json: patient.to_json(except: [:created_at, :updated_at, :password_digest], include: [comment: {except: [:created_at, :updated_at]}]) 
    end
  
    private
    def authorize
      return render json: { error: "Not authorized" }, status: :unauthorized unless session.include? :user_id
    end

    def patient_params
      params.permit(:first_name, :last_name, :username, :email, :contact_number, :clinic_location, :role, :password, :password_confirmation)
    end

    def render_not_found
      render json: { error: "Patient is not found" }, status: :not_found
    end

    def render_unprocessable_entity(invalid)
      render json: { errors: invalid.record.errors }, status: :unprocessable_entity
    end
end
