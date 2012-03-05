#
# I would love to claim credit for this code, but I cannot. It comes from the
# good folk over at metaskills.net
#
# http://www.metaskills.net/2010/5/26/the-alias_method_chain-of-rake-override-rake-task
#

Rake::TaskManager.class_eval do
  def alias_task( fq_name )
    new_name = "#{fq_name}:original"
    @tasks[new_name] = @tasks.delete(fq_name)
  end

  def remove_task( fq_name )
    @tasks.delete(fq_name.to_s)
  end
end

def alias_task( fq_name )
  Rake.application.alias_task(fq_name)
end

def override_task( *args, &block )
  name, params, deps = Rake.application.resolve_args(args.dup)
  fq_name = Rake.application.instance_variable_get(:@scope).dup.push(name).join(':')
  alias_task(fq_name)
  Rake::Task.define_task(*args, &block)
end

def remove_task( *args )
  args.flatten.each { |fq_name| Rake.application.remove_task(fq_name) }
end
alias :remove_tasks :remove_task

