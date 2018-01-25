# Rails Constant Resolution Bug

Run the test suite with:

    bin/rails test

See a failure:

```
# Running:

E

Error:
TheyWorkTest#test_the_constants_resolution_can_find_them:
LoadError: Unable to autoload constant Base, expected /Users/michael/code/ruby/constants_bug/app/workflows/base.rb to define it
    app/workflows/null.rb:2:in `<module:Workflows>'
    app/workflows/null.rb:1:in `<top (required)>'
    test/workflows/they_work_test.rb:5:in `block in <class:TheyWorkTest>'
```

The error message says that it’s looking at the correct file to load the
constant.

If you uncomment the `byebug` line on `app/workflows/base.rb:3`, you can see
that the file is being loaded.

## Attempted Solutions

These are divided into two groups: working and non-working.

### Working

1. Moving the `workflows` folder into `app/models/workflows` works, but I would
   rather not have these objects mingling with other models.
2. Adding `require_dependency ‘./base’` and `require_dependency ‘./null’` to
   `app/workflows/workflows.rb` ensures the constants can be loaded. But that
   would require me to do a `require_dependency` for every further workflow that
   I create.
3. Enabling `config.eager_load` fixes the problem.

### Non-Working

1. `require_dependency ‘./base’` to `app/workflows/null.rb` doesn’t fix the problem.
2. Changing to the inline `Workflows::Base` definition doesn’t fix the problem.
3. Upgrading to Rails 5.2.0.beta2 doesn’t fix the problem.
4. Explicitly adding `app/workflows` to `config.autoload_paths` doesn’t fix the
   problem.

## Workaround

Building off Working Solution 2, we can programmatically add `require_dependency` to
create a clever workaround. Inside of `app/workflows/workflows.rb`:

```ruby
current_path = Pathname.new(__dir__)
(Dir[current_path.join('**/*.rb')] - [__FILE__]).each do |workflow|
  path = Pathname.new(workflow).relative_path_from(current_path)

  require_dependency "./#{path}"
end
```

However, it seems like this would require the Rails server to be rebooted when
you add a new workflow class.
