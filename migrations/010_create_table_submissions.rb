Sequel.migration do
  up do
    create_table :submissions  do

      primary_key :id

      foreign_key :task_id,  :tasks,
        null:      false,
        on_delete: :cascade

      foreign_key :user_id,  :users,
        null:      false,
        on_delete: :restrict

      column      :made_on,    'timestamp with time zone',
        null:      false,
        default:   Sequel.function(:now)

      column      :revised_on, 'timestamp with time zone',
        null:      false,
        default:   Sequel.function(:now)

      String      :status,
        null:      false,
        default:   'submitted'
      validate do
        includes %w|submitted accepted rejected|, :status
      end

      # Store user submission as a JSON object with 'type' and 'value' keys.
      #
      # data = {
      #   type:  ...,
      #   value: ...
      # }
      #
      # Where 'type' tells us whether the user submitted "corrections" to the
      # focal gene model, or "comments" stating gene model is good or lack of
      # enough evidence, etc.
      column      :data, :json,
        default:   Sequel.pg_json({})
      validate do
        data = Sequel.pg_json_op(:data)
        includes %w|correction comment|, data.get_text('type')
        presence data['value']
      end
    end
  end

  down do
    drop_constraint_validations_for table: :submissions
    drop_table :submissions
  end
end
