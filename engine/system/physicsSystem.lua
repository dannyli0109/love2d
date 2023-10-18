local PhysicsSystem = {

}

function PhysicsSystem.update(dt, components)
    if components.rigidBody then
        local rigidBody = components.rigidBody
        rigidBody.velocity.x = rigidBody.velocity.x + rigidBody.acceleration.x * dt
        rigidBody.velocity.y = rigidBody.velocity.y + rigidBody.acceleration.y * dt
        rigidBody.acceleration.x = 0
        rigidBody.acceleration.y = 0
    end

    if components.transform and components.rigidBody then
        local transform = components.transform
        local rigidBody = components.rigidBody
        transform.position.x = transform.position.x + rigidBody.velocity.x * dt
        transform.position.y = transform.position.y + rigidBody.velocity.y * dt
        transform.rotation = (transform.rotation + rigidBody.angularVelocity * dt) % 360
    end
end

return PhysicsSystem
