# Mengpaneel

TL;DR: Mengpaneel makes Mixpanel a breeze to use in Rails apps by giving you a single way to interact with Mixpanel from your controllers, with Mengpaneel taking it upon itself to make sure everything gets to Mixpanel. Fast-forward to "[So&hellip; How?!](#so-how)" to get started.

#### Hi

Good morning, and thank you for coming. From the look on your face, I sense that you're wondering why I invited you here today.

#### Sure am. Why _am_ I here?

You're here because I wanted to speak with you about a little thing I built, affectionately called "Mengpaneel."

#### All right, so what is "Mengpaneel?"

"Mengpaneel" is the Dutch word for "mixing console."

#### Sigh. What does Mengpaneel _do_?

Beside the above, "Mengpaneel" is the literal Dutch translation of "[Mixpanel](https://mixpanel.com)," which you'll know as "[t]he most advanced analytics platform ever for mobile and the web."

Mixpanel is great, but there are some problems you're likely to run into when trying to use it with a large server side web app.

Mengpaneel aims to address these problems for Ruby on Rails, but the problems and abstract solution apply to any framework.

#### You've got my attention. What "problems" are these?

Let me first take a step back and explain how Mixpanel works.

Put in "Explain Like I'm 5" terms, Mixpanel gathers events that happen in your app and does magic to them.

Because Mixpanel doesn't know your app like you do, you're responsible for deciding what events to track, tracking these events and finally getting them to Mixpanel. To help you do this, Mixpanel provides tracking libraries for a bunch of common languages.

For web apps, Mixpanel's preferred tracking library is their client side [JavaScript library](https://mixpanel.com/help/reference/javascript), going as far as actively discouraging use of libraries for [server](https://mixpanel.com/help/reference/ruby) [side](https://mixpanel.com/help/reference/python) [languages](https://mixpanel.com/help/reference/php).

There's good reason for this. As they [write](https://mixpanel.com/help/reference/ruby),
> [the JavaScript library] offers platform-specific features and conveniences that can make Mixpanel implementations much simpler, and can scale naturally to an unlimited number of clients.

#### Sounds good, so let's check out this JavaScript library!

All right, here's the documentation:

> **Sending events**
> 
> Once you have the [setup] snippet in your page, you can track an event by calling `mixpanel.track` with the event name and properties.
> 
> ```js
> mixpanel.track(
>     "Clicked Ad",
>     { "Banner Color": "Blue" }
> );
> ```

#### That doesn't look too hard; let's go and sprinkle `mixpanel.track` calls all over our code!

If only it were that easy.

The example events Mixpanel uses in their library documentation ("Clicked Ad," "Played Video," etc.) have been carefully chosen to be events that exclusively happen on the client side—in the browser, where favorite child JavaScript reigns.

#### Hmm. What then about server side events? Say "Place Order," clearly a database action? 

Mixpanel suggests placing the `mixpanel.track` call on the page the user returns to after the event has happened, i.e. the "Thanks for your order" page. Problem solved!

#### "Thank you page," you say? It's 2014, my "Sign In" action redirects wherever the user initially tried to go—I don't do "thank you" pages.

And there you have our first problem.

If a "Thank you!" or "Success!" page is rendered or if the user is always redirected to the same dedicated page, placing the `mixpanel.track` call there is a fine option. But if you _don't_ know where the user will be redirected to, or if you're redirecting back to something like an "index" page, you don't want to place the track call there.

If you were clever, you could set a cookie `just_signed_in=true` just before redirecting, and place a check for that value in your app's layout view, but with dozens of different events, that's a slippery slope I don't want to go down.

Can you think of more examples of situations where Mixpanel's assumptions don't hold so well?

#### How about my "Create Blog Post" action? My `POST posts` endpoint is used by the website as well as the iPhone app—my action respects the "Accept" header, returning HTML and JSON, respectively.

If your action can be used as an API returning JSON, the JavaScript tracking library isn't going to be of much use and you're gonna be missing out on events from API users.

Mixpanel provides libraries for [iOS](https://mixpanel.com/help/reference/ios) and [Android](https://mixpanel.com/help/reference/android), but that doesn't help when the endpoint is used by 3rd party apps that you can hardly expect to send events to your Mixpanel account. Even if you don't allow 3rd party apps, integrating Mixpanel with your mobile app makes it hard to retroactively add events or event properties to your system, because updates to iOS and Android apps take a while to go out, which is gonna screw with your numbers until the app's been approved and every user has upgraded.

And that's two problems. Can you think of one more?

#### It's similar to the previous one, but what about my "Complete Payment" event? The endpoint in question is exclusively called by my payment provider to report on payment status, so it doesn't return HTML and the client isn't an app I control with its own Mixpanel library.

I'm loving this conversation, you seem to know exactly where I'm going without me needing to say a word—it's almost like I'm talking to myself.

Indeed, the third problem is with isolated endpoints that don't have access to any client side library to track events.

#### These all seem like very common situations, are you seriously saying Mixpanel is somehow oblivious to this?

I'm not. Mixpanel is definitely aware of this, which is where the aforementioned [server](https://mixpanel.com/help/reference/ruby) [side](https://mixpanel.com/help/reference/python) [libraries](https://mixpanel.com/help/reference/php) come in.

As they [write](https://mixpanel.com/help/reference/ruby),
> [t]he Mixpanel Ruby library is designed to be used for scripting, or in circumstances when a user isn't directly interacting with your application on the web or a mobile device.

Indeed, all of the problems you so pointedly pointed out can be solved by simply doing the event tracking from the server side. Instead of `mixpanel.track` calls in your views, you'll be having `mixpanel.track` calls in your controller actions.

#### So what's the big deal then? Why did I have to read almost a thousand words to reach this conclusion? _Why is Mengpaneel at all?_

Remember my saying the JavaScript library was Mixpanel's preferred tracking library? Remember my first quote from the Mixpanel documentation? Let me recite it again, because it's been a while:
> [the JavaScript library] offers platform-specific features and conveniences that can make Mixpanel implementations much simpler, and can scale naturally to an unlimited number of clients.

If you move away from the JavaScript library and use the Ruby library everywhere instead, you lose all of that. 

One feature only readily available to the JavaScript library is the ability to link a user's previously anonymous behavior browsing your promotion website to their newly created account when they sign up. How valuable it is to know what your user did _before_ they became part of the priviliged group who decided to actually sign up cannot be overstated.

Second, information about the user's device, OS and browser is very interesting, but not available to the Ruby library unless you jump through some hoops with user agent parsing on every request.

Last, but definitely not least: the JavaScript library scales infinitely, while the Ruby library... doesn't. You don't want your server busy sending tens of thousands of events a day to Mixpanel, when it could be serving new (revenue generating!) requests instead.

#### That makes a lot of sense. I can't believe Mixpanel hasn't properly addressed this. So how does Mengpaneel solve these problems? I'm assuming you want to sell me your magic bullet?

You've got me :) 

Mengpaneel addresses the problems mentioned by giving you a single way to interact with Mixpanel from your server side app, with Mengpaneel taking it upon itself to make sure everything gets to Mixpanel, using the best strategy available, whether it be client side, server side or something completely different.

You can call all the "mixpanel.whatever" methods you know and love from the JavaScript library, right from your your Rails controllers, without having to worry about lack of thank you pages, unpredictable redirects, AJAX requests, endpoints with multiple response content types and clients outside your control.

#### So&hellip; How?!

First, install Mengpaneel by adding it to your Gemfile:

```ruby
gem "mengpaneel"
# Don't forget to `bundle install`
```

Second, configure Mengpaneel with your Mixpanel token:

```ruby
# config/initializers/mengpaneel.rb

Mengpaneel.configure do |config|
  config.token = "abc123" # or use ENV["MIXPANEL_TOKEN"] if you're into 12-factor. It's not set automatically though, you still have to put that line.
end
```

Third, include Mengpaneel in the controller(s) you plan to track Mixpanel events from. Include it in your `ApplicationController` if you want to use Mixpanel _everywhere_:

```ruby
class ApplicationController < ActionController::Base
  include Mengpaneel::Controller
end
```

Fourth, always identify the currently signed in user with Mixpanel:

```ruby
class ApplicationController < ActionController::Base
  # ...

  before_action :setup_mixpanel

  private
    def setup_mixpanel
      return unless user_signed_in?

      # For technical reasons, you need to do setup from a `mengpaneel.setup` block.
      # I'll go into those reasons later.
      mengpaneel.setup do
        mixpanel.identify(current_user.id)

        mixpanel.people.set(
          "ID"              => current_user.id,
          "$email"          => current_user.email,
          "$first_name"     => current_user.first_name,
          "$last_name"      => current_user.last_name,
          "$created"        => current_user.created_at,
          "$last_login"     => current_user.current_sign_in_at
        )
      end
    end
end
```

Fifth, let Mixpanel know when an anonymous user got an identity (i.e. signed up):

```ruby
class RegistrationsController < Devise::RegistrationsController
  # Devise::RegistrationsController automatically extends ApplicationController.

  def create
    # The Devise::RegistrationsController#create action yields to its caller
    # so you can easily extend it with custom behaviour, like we do here!
    super do
      # We need to make sure signing up actually succeeded.
      if resource.errors.blank?
        # Technical reasons again, will get into those later.
        mengpaneel.before_setup do
          mixpanel.alias(resource.id)
        end

        mixpanel.track("Sign Up", "ID"          => current_user.id,
                                  "Email"       => current_user.email,
                                  "First name"  => current_user.first_name,
                                  "Last name"   => current_user.last_name)
      end
    end
  end
end
```

Fourth, track Mixpanel events:

```ruby
class SessionsController < Devise::SessionsController
  def create
    super do
      mixpanel.track("Sign In")
    end
  end

  def destroy
    super do
      mixpanel.track("Sign Out")
    end
  end
end
```

```ruby
class PostsController < ApplicationController
  respond_to :html, :json

  def create
    @post = Post.new(post_params)

    respond_with(@post) do |format|
      if @post.save
        mixpanel.track("Create Blog Post", "Title" => @post.title)

        format.html do
          flash[:notice] = "Successfully created blog post!"

          redirect_to post_path(@post)
        end

        format.json do
          render json: @post
        end
      end
    end
  end

  private
    def post_params
      params.require(:post).permit(:title, :body)
    end
end
```

```ruby
class PaymentNotificationsController < ApplicationController
  before_action :authenticate!

  def notify
    if params[:status] == "payment_complete"
      @payment = Payment.find(params[:payment_id])
      @payment.status = :paid
      @payment.save!

      mixpanel.track("Complete Payment",  "Payment ID"  => @payment.id,
                                          "Amount"      => @payment.amount)
    end

    response.content_type = "text/plain"
    render text: "[accepted]"
  end

  private
    def authenticate!
      authenticate_or_request_with_http_basic do |username, password|
        username == "payments" && password == "ftw"
      end
    end
end
```

Finally, if you want to track events from a script or background worker instead of a controller, you can use `Mengpaneel::Manager` directly, like this:

```ruby
class SubscriptionRenewalWorker
  include Sidekiq::Worker

  def perform(subscription_id)
    subscription = Subscription.find(subscription_id)

    subscription.renew!

    Mengpaneel::Manager.new do |mengpaneel|
      mengpaneel.setup do |mixpanel|
        mixpanel.identify(subscription.user.id)
      end
      
      # Because the `mixpanel` method exposed in your controllers isn't 
      # available here, you need to get it explicitly from Mengpaneel.
      mengpaneel.tracking do |mixpanel|
        mixpanel.track("Renew Subscription", "Subscription ID" => subscription.id)
      end
    end
  end
end
```

#### No, no, I mean, how does Mengpaneel do all this?

This is where it gets fun. 

Basically, Mengpaneel works in three stages. In describing them, it's easiest to go from back to front, so let's start with the third and final Mengpaneel stage: 

###### Flush

In the Flush stage, Mengpaneel makes sure events actually get to Mixpanel.

As said, Mengpaneel is smart enough to decide by itself how to flush events using the best strategy available, whether it be client side, server side or something completely different.

Since the problems discussed above all have to do with properties of the incoming request or outgoing response, Mengpaneel waits until you've finished building the response and then chooses a strategy by looking at the request and response.

In order, these are the strategies considered:

-   `Delayed`: If the response is going to be a redirect, we can't use the JavaScript library to flush events. We could immediately give up and use the Ruby library, but most of the time redirects are inbound so we'll get to a non-redirect page of our app eventually. 

    Thus, we delay flushing events for now, saving them in a session to be considered in the next request.

-   `ClientSide`: If the response isn't a redirect, using the JavaScript library is our best option for reasons mentioned earlier. We just need to verify that we're actually in an environment where JavaScript will be executed. That is, the response content type is HTML, we're not being requested using AJAX, we're not being downloaded as an attachment and we're not streaming data.

    If all of these requirements are met, we flush all events by injecting calls to the JavaScript library into the response body.

-   `CapableClientSide`: If injecting the JavaScript calls isn't going to work, our only option is to use the server side Ruby library, right? Well, not quite. Even if we can't get our code to be executed on the client side directly, we _can_ work something out with the client that's calling us, if they're willing and capable.

    In this case, "capable" means that the client calling us is itself in a position to flush events to Mixpanel, and that if the server (that's us) were to give them a list of events they'd like to end up at Mixpanel, they would simply pass them along. "Willing" means they're actually advertising that capability, to be picked up on by the server.

    To advertise this capability, the client adds the `X-Mengpaneel-Flush-Capable` header with value `true` to their request headers. Mengpaneel running on the server will pick up on this, and flush all tracking calls by putting them in a JSON-serialized array in the `X-Mengpaneel-Calls` response header.

    When the client receives this response, it's their responsiblility to actually flush those calls to Mixpanel, by deserializing the header's contents, iterating over the events and calling the appropriate methods on the client side Mixpanel library.

    This is a very useful feature in web apps with a very AJAX-heavy front end or in mobile apps, where most events would otherwise have to be flushed using the server side library but can now be flushed on the client side.

    Mengpaneel comes with a small JavaScript library that does exactly what's described above for jQuery-based web apps. Install it by adding the following code to your app's main JavaScript file, after jQuery:

    ```js
    //= require jquery
    //= require mengpaneel
    ```

    A library accomplishing the same thing should be trivial to write for iOS or Android.

-   `AsyncServerSide`: And now we've arrived at our final option: using the server side Ruby library. Flush the events to Mixpanel from the same thread where the request is being handled would cause a small slowdown, so we've got one last trick up our sleeve.

    If you have [Sidekiq](http://sidekiq.org/) installed, we'll queue a worker that will flush the events, to be handled by Sidekiq at a later time.

    This asynchronous worker simply delegates to the last available strategy, which is also the one that will be used directly if Sidekiq isn't available, namely:

-   `ServerSide`: And now we're at the _actual_ final option. If none of the other strategies where available, we use the official [`mixpanel-ruby`](https://github.com/mixpanel/mixpanel-ruby) gem to flush the events to Mixpanel right from our server side process.

    At this point, some translation takes place from the JavaScript library API to the Ruby library API, to ensure you can write your controller calls as you would using the JavaScript library, while still doing The Right Thing<sup>TM</sup>.

And that's end of Flush, by far the most exciting stage in Mengpaneel. More important in the grand scheme of things however, is:

###### Tracking

In the Tracking stage, Mengpaneel doesn't actually do all that much. This stage is filled in by your own controller; it's where you call Mixpanel methods like `alias`, `identify`, `people.set` and `track`.

Mengpaneel's main responsibility is keeping track of all of the Mixpanel calls you make. Since we don't send them to Mixpanel immediately, but wait to do so until the Flush stage, we use a so-called `CallProxy` to pick up all calls so we can store them and handle them later.

For technical reasons, Mengpaneel does interfere a little in this stage; you've already seen the `mengpaneel.setup` and `mengpaneel.before_setup` calls.

Because Mengpaneel can delay calls until the next request, we need to make sure calls like `mixpanel.identify` and `mixpanel.people.set` aren't repeated when the next request's `mixpanel_setup` before-action is fired, because this would cause unnecessary requests to be sent to Mixpanel and would cause a flood of these when we're dealing with a chain of multiple redirects, each adding calls onto the one before it.

We also need to make sure `mixpanel.alias` calls are always flushed _before_ `mixpanel.identify` calls, since they need access to the original anonymous distinct user ID.

For this reason, Mengpaneel knows three modes, aptly named `before_setup`, `setup` and `tracking`—the default. To temporarily switch to a mode, simply wrap your event-tracking calls in a `mengpaneel.before_setup` or `mengpaneel.setup` block, as shown in the examples I gave before.

In Flush, calls from these three modes are always called in this order, so `mixpanel.alias` comes before `mixpanel.identify` comes before `mixpanel.track`.

Additionally, `mengpaneel.setup` overwrites `mengpaneel.setup` calls made earlier, thus preventing the flood of `mixpanel.identify` and `mixpanel.people.set` calls that would happen with delayed calls after a redirect.

Lastly, explicitly identifying calls as "setup" or "tracking" allows us to optimize the `[Async]ServerSide` strategy by doing nothing if no actual tracking calls were made. If we're not sending events, there's no need to do setup at all.

With tracking finished, we've arrived at the first stage to be executed and the last stage to be discussed, called:

###### Replay

In the Replay stage, Mengpaneel replays previously delayed calls.

As mentioned under Flush, the `Delayed` strategy delays flushing calls until the next request if the current one is a redirect by saving them in a session.

Before your controller action is called, Replayer does nothing more than reading this session, iterating over the calls saved therein and calling them in their respective tracking modes, just like you did from inside your controller action in the previous request, thus making sure no delayed calls get lost.

And there you have it!

#### Dude. Who are you, I mean, who should I thank for this?

My name is [Douwe Maan](http://www.douwemaan.com) and I'm a co-founder-slash-developer at [Stinngo](http://www.stinngo.com).

Besides that, you should thank [Mixpanel](https://mixpanel.com) since without them this project would've been very pointless indeed, as well as gems [event_tracker](https://github.com/doorkeeper/event_tracker) and [analytical](https://github.com/jkrall/analytical) from which I've taken inspiration.

#### Cool. And I can just, like, use this in my apps?

Sure, as long as you adhere to the following license:

> Copyright (c) 2014 Douwe Maan
> 
> MIT License
> 
> Permission is hereby granted, free of charge, to any person obtaining
> a copy of this software and associated documentation files (the
> "Software"), to deal in the Software without restriction, including
> without limitation the rights to use, copy, modify, merge, publish,
> distribute, sublicense, and/or sell copies of the Software, and to
> permit persons to whom the Software is furnished to do so, subject to
> the following conditions:
> 
> The above copyright notice and this permission notice shall be
> included in all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
> LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
> OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
> WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
