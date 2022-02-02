namespace :dev do

  DEFAULT_PASSWORD = 123456
  DEFAULT_FILES_PATH = File.join(Rails.root, 'lib', 'tmp')

  desc "Configura o ambiente de desenvolvimento"
  task setup: :environment do
    if Rails.env.development?
      show_spinner("Apagando BD...") { %x(rails db:drop) }
      show_spinner("Criando BD...") { %x(rails db:create) }
      show_spinner("Migrando BD...") { %x(rails db:migrate) }
    end

    show_spinner("Cadastrando usuário...") { %x(rails dev:add_default_user) }
    show_spinner("Cadastrando Admin...") { %x(rails dev:add_default_admin) }
    show_spinner("Cadastrando Admin Extra...") { %x(rails dev:add_extra_admins) }
    show_spinner("Cadastrando assuntos Padrões...") { %x(rails dev:add_subjects) }
    show_spinner("Cadastrando perguntas e respostas...") { %x(rails dev:answers_and_questions) }
    #else
      #puts "Você não está em ambiente de desenvolvimento!"
    #end
  end

  desc "Adiciona o usuário padrão"
  task add_default_user: :environment do
    User.create!(
      email: 'user@user.com',
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc "Adiciona o administrador padrão"
  task add_default_admin: :environment do
    Admin.create!(
      email: 'admin@admin.com',
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc "Adiciona o administrador extra"
  task add_extra_admins: :environment do
    10.times do |i|
      Admin.create!(
        email: Faker::Internet.email,
        password: DEFAULT_PASSWORD,
        password_confirmation: DEFAULT_PASSWORD
      )
    end
  end

  desc "Adiciona assuntos padrões"
  task add_subjects: :environment do
    file_name = 'subjects.txt'
    file_path = File.join(DEFAULT_FILES_PATH, file_name)

    File.open(file_path, 'r').each do |line|
      Subject.create!(description: line.strip)
    end
  end

  desc "Adiciona perguntas e respostas"
  task answers_and_questions: :environment do
    Subject.all.each do |subject|
      rand(3..10).times do |i|
        params = create_question_params(subject)
        answers_array = params[:question][:answers_attributes]

        add_answers(answers_array)
        elected_true_answer(answers_array)

        Question.create(params[:question])
      end
    end
  end

  desc "Reset contador assuntos"
  task reset_subject_counter: :environment do
    show_spinner("Reset contador assuntos...") do
      Subject.find_each do |subject|
        Subject.reset_counters(subject.id, :questions)
      end
    end
  end

  private

  def elected_true_answer(answers_array = [])
    selected_index = rand(answers_array.size)
    answers_array[selected_index] = create_answer_params(true)
  end

  def add_answers(answers_array = [])
    rand(3..5).times do |j|
      answers_array.push(
        create_answer_params
      )
    end
  end

  def create_answer_params(correct = false)
    { description: Faker::Lorem.sentence, correct: correct }
  end

  def create_question_params(subject = Subject.all.sample)
    { question: {
      description: "#{Faker::Lorem.paragraph} #{Faker::Lorem.question}",
      subject: subject,
      answers_attributes: []
    } }
  end

  def show_spinner(msg_start, msg_end = "Concluído!")
    spinner = TTY::Spinner.new("[:spinner] #{msg_start}")
    spinner.auto_spin
    yield
    spinner.success("(#{msg_end})")
  end
end
